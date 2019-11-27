output "ServerNames" {
  value = "${map("rw","sql-${lower(var.BaseName)}-fg","ro","sql-${lower(var.BaseName)}-fg.secondary")}"
}
output "DatabaseNames_StageSlot" {
  value = "${map("Services","DB-${var.BaseName}-${var.appslot["Secondary"]}-Services","Logs","DB-${var.BaseName}-${var.appslot["Secondary"]}-Logs")}"
}
output "DatabaseNames_ProdSlot" {
  value = "${map("Services","DB-${var.BaseName}-${var.appslot["Primary"]}-Services","Logs","DB-${var.BaseName}-${var.appslot["Primary"]}-Logs")}"
}
output "DatabaseBaseName" {
  value = "${var.BaseName}"
}
