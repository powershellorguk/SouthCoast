if ($PSVersionTable.PSVersion -ge [version]"5.0") {
    Register-ArgumentCompleter -CommandName Get-Timezone, Set-Timezone -ParameterName Timezone -ScriptBlock {
        # This is the argument completer to return available timezone
        # parameters for use with getting and setting the timezone.
        Param(
            $commandName,        #The command calling this arguement completer.
            $parameterName,      #The parameter currently active for the argument completer.
            $currentContent,     #The current data in the prompt for the parameter specified above.
            $commandAst,         #The full AST for the current command.
            $fakeBoundParameters #A hashtable of the current parameters on the prompt.
        )

        $tz = Get-Timezone -All
        $tz | Where-Object { $_.Timezone -like "$($currentContent)*" } | ForEach-Object {
            $CompletionText = $_.Timezone
            if ($_ -match '\s') {
                $CompletionText = "'$($_.Timezone)'"
            }

            New-Object System.Management.Automation.CompletionResult (
                $CompletionText,                     #Completion text that will show up on the command line.
                "$($_.Timezone) ($($_.UTCOffset))",  #List item text that will show up in intellisense.
                'ParameterValue',                    #The type of the completion result.
                "$($_.Timezone) ($($_.UTCOffset))"   #The tooltip info that will show up additionally in intellisense.
            )
        }
    }
}