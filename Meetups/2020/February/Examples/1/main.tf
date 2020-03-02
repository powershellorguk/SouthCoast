provider "random" {}

resource "random_pet" "test" {
	length = 4
	separator = "-"
	count = 6
}

output "petName" {
  value = random_pet.test.*.id
}
