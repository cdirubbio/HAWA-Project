output "priv_subnet_ids" {
  value = aws_subnet.priv_subnet[*].id
}
output "pub_subnet_ids" {
  value = aws_subnet.pub_subnet[*].id
}