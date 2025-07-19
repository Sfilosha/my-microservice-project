terraform {
  backend "s3" {
    bucket         = "a1293djai9123ujda"
    key            = "lesson-5/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

