#Requires -Module Pester
. $PSScriptRoot\Shared.ps1

InModuleScope Example {
    Describe 'Get-Timezone' {
        Context 'UTC' {
            It 'Returns the current Timezone object' {
                $timezone = Get-Timezone
                $timezone.Timezone | Should Not Be $null
                $timezone.UTCOffset | Should Not Be $null
                $timezone.ExampleLocation | Should Not Be $null
            }
        }

        Context 'Ahead of GMT timezone' {
            It 'Returns a Singapore (UTC+08:00) Timezone object' {
                $timezone = (Get-Timezone -Timezone 'Singapore Standard Time')
                $timezone.Timezone | Should Be 'Singapore Standard Time'
                $timezone.UTCOffset | Should Be '+08:00'
                $timezone.ExampleLocation | Should Be '(UTC+08:00) Kuala Lumpur, Singapore'
            }
        }

        Context 'Behind GMT timezone' {
            It 'Returns a Central America (UTC-06:00) Timezone object' {
                $timezone = (Get-Timezone -Timezone 'Central America Standard Time')
                $timezone.Timezone | Should Be 'Central America Standard Time'
                $timezone.UTCOffset | Should Be '-06:00'
                $timezone.ExampleLocation | Should Be '(UTC-06:00) Central America'
            }
        }

        Context 'UTCOffset' {
            It 'Checks the UTCOffset parameter implicit positive returns data' {
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset '00:00') -DifferenceObject (Get-Timezone -UTCOffset '+00:00') | Should Be $null
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset '00:00') -DifferenceObject (Get-Timezone -UTCOffset '-00:00') | Should Be $null
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset '01:00') -DifferenceObject (Get-Timezone -UTCOffset '+01:00') | Should Be $null
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset '10:00') -DifferenceObject (Get-Timezone -UTCOffset '+10:00') | Should Be $null
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset '05:45') -DifferenceObject (Get-Timezone -UTCOffset '+05:45') | Should Be $null
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset '09:30') -DifferenceObject (Get-Timezone -UTCOffset '+09:30') | Should Be $null
            }
        }

        Context 'Multiple Offset' {
            It 'Checks multiple offsets are handled' {
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset ((Get-Timezone -All).UTCOffset | Select-Object -Unique)) -DifferenceObject (Get-Timezone -All) | Should Be $null
                Compare-Object -ReferenceObject (Get-Timezone -UTCOffset '02:00', '03:00') -DifferenceObject (Get-Timezone -All | Where-Object UTCOffset -Match "\+0[2-3]\:00") | Should Be $null
            }
        }

        Context 'Match Parametersets' {
            It 'Checks timezones returned via -UTCOffset can be matched to timezone objects' {
                $timezones = Get-Timezone -All
                $timezones | Select-Object -Unique -Property UTCOffset | ForEach-Object {
                    { Get-Timezone -UTCOffset $_ -eq Get-Timezone -All | Where-Object UTCOffset -eq $_ } | Should Be $True
                }
            }
        }

        Context 'All' {
            It 'Checks all timezones for consistency with individual data return' {
                $timezone = Get-Timezone -All
                Get-Timezone -All | Get-Timezone | ForEach-Object {
                    $timezone.Timezone -contains $_.Timezone | Should Be $true
                    $timezone.UTCOffset -contains $_.UTCOffset | Should Be $true
                    $timezone.ExampleLocation -contains $_.ExampleLocation | Should Be $true
                }
            }
        }

        Context 'Multiple' {
            It 'Returns multiple individual timezones' {
                { Get-Timezone -Timezone 'Eastern Standard Time', 'SA Pacific Standard Time' } | Should Not Throw
            }
        }

        Context 'PipelineInput' {
            It 'Returns a timezone from pipeline data by value' {
                'UTC' | Get-Timezone | Should Not Be $null
                'utc' | Get-Timezone | Should Not Be $null
            }

            It 'Returns a timezone from pipeline data by property name' {
                 Get-Timezone -Timezone 'Pacific Standard Time' | Get-Timezone | Should Not Be $null
            }
        }

        Context 'Validation' {
            It 'Tries to get an invalid timezone' {
                { Get-Timezone -Timezone 'My First Timezone' } | Should Throw
                { Get-Timezone -Timezone 0 } | Should Throw
                { Get-Timezone -Timezone 19:00 } | Should Throw
                { Get-Timezone -UTCOffset 'Another Timezone' } | Should Throw
            }
        }
    }

    Describe 'Set-Timezone-UTC' {
        Context 'Standard' {
            It 'Sets the timezone to UTC' {
                Set-Timezone -Timezone 'UTC' -WhatIf | Should Be $null
            }
        }

        Context 'PipelineInput' {
            It 'Sets the timezone from pipeline data' {
                'Dateline Standard Time' | Set-Timezone -WhatIf | Should Be $null
            }

            It 'Returns a timezone from pipeline data by property name' {
                 Get-Timezone -Timezone 'Hawaiian Standard Time' | Set-Timezone -WhatIf | Should Be $null
            }
        }

        Context 'Validation' {
            It 'Tries to set an invalid timezone' {
                { Set-Timezone -Timezone 'My First Timezone' } | Should Throw
            }
        }
    }
}