# TF code to deploy Catalyst SD-WAN in AWS with TGW

Cisco Catalyst SD-WAN Cloud OnRamp provides automated solution for initial deployment. For customer with existing cloud enviorment, the prescriptive nature may not meet their design requirements. Customer requires additional flexibility for the deployment of their cloud gateway instances.

The deployment of this option can be done using Infrastructure as Code (IaC) tools such as Terraform.  This tf code can be used for deployment of following design in AWS enviorment with existing TGW. 

 ## AWS Deployment Procedure:
  
- Create a Transit VPC to launch the redundant cloud gateways (Cat8000v).
- Set up four subnets within the Transit VPC to segregate the network traffic.
   
  ... a. One subnet for Public Internet
  ... b. One subnet for Private Transport (DX to on-prem)
  ... c. One subnet for Service VPN
  ... d. One subnet for Management 
  
- Create four separate route tables, one for each subnet, to define the routing behavior.
- Create four Network Interfaces for each cloud gateway(Cat8000v) within the Transit VPC.
  ... a. One Network Interface for Public transport 
  ... b. One Network Interface for Private transport 
  ... c. One Network Interface for Service VPN 
  ... d. One Network Interface for OOB Management
- Reserve Public IP (Elastic IP) for Cloud Gateways and associate the reserved IP with network interface for public transport
- Configure security groups to control the inbound and outbound traffic for the cloud gateways.
- Associate the subnets with the appropriate route tables.
- Attach the security group to the network interface.
- Create a startup configuration for the cloud gateways, defining their initial settings.
- Deploy the cloud gateways with the specified startup configuration.
- Onboard the deployed cloud gateways onto the SD-WAN Manager controller for centralized management.
- Attach the Transit VPC to the existing Transit Gateway (TGW) to establish connectivity.
- Create connect connections (GRE)between the Transit VPC and the Cloud Gateway.
- Update the configuration of the cloud gateways to include GRE and BGP configuration for proper functionality.





•	Create a startup configuration for the cloud gateways, defining their initial settings.
•	Deploy the cloud gateways with the specified startup configuration.
•	Onboard the deployed cloud gateways onto the SD-WAN Manager controller for centralized management.
•	Attach the Transit VPC to the existing Transit Gateway (TGW) to establish connectivity.
•	Create connect connections (GRE)between the Transit VPC and the Cloud Gateway.
•	Update the configuration of the cloud gateways to include GRE and BGP configuration for proper functionality.
