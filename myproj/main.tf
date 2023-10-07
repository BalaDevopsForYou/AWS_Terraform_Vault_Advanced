module "mymodule" {

    source = "../modules/myproject_vpc"
    projectname = var.projectname

    region = var.region

    myvpc_cidr=var.myvpc_cidr

    mysubnet1_cidr=var.mysubnet1_cidr

    mysubnet2_cidr=var.mysubnet2_cidr
}