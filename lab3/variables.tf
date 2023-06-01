variable "subnet_type" {
  default = {
    public  = "public"
    private = "private"
  }
}
variable "cidr_ranges" {
  default = {
    public1  = "10.0.1.0/24"
    public2  = "10.0.2.0/24"
    private1 = "10.0.3.0/24"
    private2 = "10.0.4.0/24"
  }
}
