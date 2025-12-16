# Power BI Desktop on AWS EC2 (macOS IaC Agent)

This project provisions a Free Tier–friendly Windows Server 2022 EC2 instance with Power BI Desktop, using Terraform and AWS SSM for secure RDP (no inbound 3389). All steps are macOS-native.

---

## A) macOS Prerequisites (auto-install)

1. **Homebrew:**
   - If missing, install:
     ```sh
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```
     - Apple Silicon:
       ```sh
       echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile && eval "$(/opt/homebrew/bin/brew shellenv)"
       ```
     - Intel:
       ```sh
       echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile && eval "$(/usr/local/bin/brew shellenv)"
       ```

2. **Terraform CLI** (default):
   ```sh
   brew tap hashicorp/tap && brew install hashicorp/tap/terraform
   ```
   - Or **OpenTofu** (drop-in replacement):
     ```sh
     brew update && brew install opentofu
     ```

3. **AWS CLI v2:**
   ```sh
   brew install awscli
   ```
   - If Homebrew fails:
     ```sh
     curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg" && sudo installer -pkg AWSCLIV2.pkg -target /
     ```

4. **AWS SSM Session Manager plugin:**
   - Apple Silicon:
     ```sh
     curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/session-manager-plugin.pkg" -o "session-manager-plugin.pkg" && sudo installer -pkg session-manager-plugin.pkg -target / && sudo ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin
     ```
   - Intel:
     ```sh
     curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/session-manager-plugin.pkg" -o "session-manager-plugin.pkg" && sudo installer -pkg session-manager-plugin.pkg -target / && sudo ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin
     ```

5. **RDP client:**
   - [Windows App for Mac (App Store)](https://apps.apple.com/us/app/windows-app/id1295203466?mt=12)

6. **Verify:**
   - `terraform -version` or `tofu -version`
   - `aws --version`
   - `session-manager-plugin`

---

## B) Deploy Windows + Power BI Desktop

1. **Configure AWS CLI (named profile):**
   ```sh
   aws configure --profile re_prabhakaran
   ```
   - Use IAM admin keys (not root). [Best practice](https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-best-practices.html)

- **Account:** 3005-5311-2090 — this Terraform configuration will operate against this AWS account when using the `re_prabhakaran` profile.

2. **Deploy:**
   ```sh
   terraform init && terraform apply -auto-approve
   # Or, with OpenTofu:
   tofu init && tofu apply -auto-approve
   ```

3. **RDP via SSM port-forward:**
   ```sh
   aws ssm start-session --target <instance-id> --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=55678,portNumber=3389"
   ```
   - Connect Windows App (RDP) to `localhost:55678`.

4. **Destroy when done:**
   ```sh
   terraform destroy -auto-approve
   # Or, with OpenTofu:
   tofu destroy -auto-approve
   ```
   - **Stay within Free Tier!**

---

## C) AWS Budgets (Optional)

- [Set up a $5 budget alert](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create.html) to catch surprise spend.

---

## D) Notes

- **No inbound 3389:** RDP is tunneled via SSM Session Manager (no public RDP exposure).
- **Power BI Desktop:** Download URL is in `variables.tf` (`PBID_URL`).
- **Free Tier:** Uses t3.micro and 30GB gp3 EBS.
- **IAM:** EC2 gets SSM role only.
- **Root user:** Do not use for daily work; create an IAM admin and enable MFA.

---

## References
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS SSM Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Power BI Desktop silent install](https://www.appdeploynews.com/app-tips/microsoft-powerbi-desktop-2-130-754-0/)
- [AWS Free Tier](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-eligibility.html)
