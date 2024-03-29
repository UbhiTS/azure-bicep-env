# azure-bicep-env

This repo is the baseline Azure network infrastructure for your dev/test needs
Deploy an n-region (primary, secondary, tertiary) hub-and-spoke extended star topology

Deployment Scenarios
------------------------------------------
- Azure AD Domain Services in the primary hub
- Azure Bastion for accessing VMs
- Regular and GPU VMs in the Hubs (DMZ Subnet)
- Firewall with 2 secured spokes in all Hubs including pre-defined inter-spoke and inter-hub routing with firewall rules
- AVD distributed environment (including GPU based VMs)

Architecture Diagram (Deployed Components)
------------------------------------------
![azure-bicep-hub-spoke](https://github.com/UbhiTS/azure-bicep-env/assets/3799525/c941e8d0-14b4-498e-babd-9b67f852d6de)

