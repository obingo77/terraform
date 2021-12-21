terraform {
required_version = ">= 1.1.0"
cloud {
    organization = "makenzi"
    workspaces  {
     name = "terraform"
        
    }    
 }
}