# Lab Overview

Success breeds more business, but your customers now need to be supported.  A new Customer Support application has been developed to assist Contoso customers with any issues encountered with the Contoso Ads Application.  Contoso have decided to take advantage of a microservices architecture for ongoing development and maintenance of this new application.  You will prepare the new Application for deployment and upload the image for provisioning to an Azure Container Registry.

## Learning Objectives

In this lab, you will learn how to work with Docker images and containers, and with the Azure Container Registry.

You will:

- Provision a new Azure SQL Database for the Contoso Ads Support web application

- Construct a Dockerfile and use it to build a docker image based off the Microsoft ASP.NET image that contains the Contoso Customer Support web application

- Run a local container from the image you constructed

- Provision an Azure Container Registry

- Push the Contoso Customer Support image to a container registry

## Naming Conventions

Throughout the exercises, you will need to define names for different Azure Resources (Resource Groups, Virtual Machines, Virtual Networks,…).

__To guarantee the uniqueness of those resources please add *your* alias to the front of all names resources you create followed by a dash.__

Some examples:

- __billg-rg__ for Azure Resource Group

- __billg-vm1__ for an Azure Virtual Machine

- __billg-stor1__ for an Azure Storage Account

- __billg-webapp1__ for an Azure Web App
