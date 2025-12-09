
You are a DevOps Copilot Agent executing on macOS (Apple Silicon or Intel). Build a ready-to-run IaC project that:

(A) **Auto-installs prerequisites on macOS** if missing
(B) Provisions a Free-Tier–friendly Windows EC2 and silently installs Power BI Desktop
(C) Provides secure RDP access via AWS Systems Manager Session Manager (no inbound 3389)
(D) Guides the user to destroy to avoid charges

────────────────────────────────────────────────────────────────────────
A) macOS PRECHECKS & AUTO-INSTALL STEPS
────────────────────────────────────────────────────────────────────────
1) Detect architecture and Homebrew:
   - If `brew` is not present, install Homebrew:
     `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
     Then add to shell:
     - Apple Silicon: `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile && eval "$(/opt/homebrew/bin/brew shellenv)"`
     - Intel: `echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile && eval "$(/usr/local/bin/brew shellenv)"`
   - Rationale: HashiCorp and the wider macOS ecosystem document Homebrew as the straightforward way to install Terraform and developer CLIs. [1](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)[3](https://www.slingacademy.com/article/ways-to-install-terraform-on-mac/)

2) Install IaC engine (choose one, default = Terraform CLI from HashiCorp tap):
   - Default (Terraform): `brew tap hashicorp/tap && brew install hashicorp/tap/terraform`
     (Official method per HashiCorp’s install guide; supports macOS and versioned updates.) [1](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   - Alternative (OpenTofu): `brew update && brew install opentofu`
     (OpenTofu is a community fork and drop‑in replacement, available in Homebrew core.) [2](https://opentofu.org/docs/intro/install/homebrew/)[4](https://formulae.brew.sh/formula/opentofu)

3) Install AWS CLI v2:
   - Preferred (Homebrew): `brew install awscli` (simple and native on macOS) [5](https://code2care.org/howto/installing-aws-cli-version-2-macos-sonoma-terminal/)
   - Official universal macOS installer (if brew fails):  
     `curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg" && sudo installer -pkg AWSCLIV2.pkg -target /`  
     (AWS now ships **universal** installers that run natively on Apple Silicon and Intel.) [6](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)[7](https://aws.amazon.com/blogs/devops/introducing-universal-installers-for-aws-cli-v2-on-macos/)

4) Install the **AWS Systems Manager Session Manager plugin** (required for CLI RDP port‑forward):
   - Apple Silicon (signed pkg):  
     `curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/session-manager-plugin.pkg" -o "session-manager-plugin.pkg" && sudo installer -pkg session-manager-plugin.pkg -target / && sudo ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin`
   - Intel (signed pkg):  
     `curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/session-manager-plugin.pkg" -o "session-manager-plugin.pkg" && sudo installer -pkg session-manager-plugin.pkg -target / && sudo ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin`
   - (If needed, bundled ZIP path is documented as well.) [8](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html)[9](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
   - NOTE: There’s a Homebrew cask too (`brew install --cask session-manager-plugin`) but AWS docs prefer the official pkg paths; Homebrew cask is currently marked deprecated timeline-wise. [10](https://formulae.brew.sh/cask/session-manager-plugin)

5) Install an RDP client for macOS:
   - Use **Windows App for Mac** (successor to Microsoft Remote Desktop) from the Mac App Store.  
     (Microsoft is transitioning from Remote Desktop to Windows App on macOS.) [11](https://apps.apple.com/us/app/windows-app/id1295203466?mt=12)[12](https://learn.microsoft.com/en-us/answers/questions/2077494/the-remote-desktop-app-seems-to-have-been-retired)

6) Verify tools:
   - `terraform -version` or `tofu -version` should print versions. (Terraform install via Homebrew tap is documented by HashiCorp.) [1](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   - `aws --version` prints AWS CLI v2 info. (Installation methods documented by AWS.) [6](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - `session-manager-plugin` should be in PATH. (Install steps and symlink per AWS docs.) [8](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html)

────────────────────────────────────────────────────────────────────────
B) TERRAFORM PROJECT TO DEPLOY WINDOWS + POWER BI DESKTOP
────────────────────────────────────────────────────────────────────────
**Repo tree to generate:**
- `providers.tf` (AWS provider, region default `ap-south-1`)
- `variables.tf` (region, instance_type=t3.micro, volume_size=30, tags, PBID_URL)
- `data_ami.tf` (latest Windows Server 2022 AMI: owners=801119661308; name `Windows_Server-2022-English-Full-Base-*`)
- `network.tf` (VPC, subnet, IGW, route table)
- `security.tf` (SG with no inbound; outbound HTTPS)
- `iam.tf` (role + instance profile `AmazonSSMManagedInstanceCore`)
- `ec2.tf` (aws_instance w/ IMDSv2 required, gp3 30GB, user data from file)
- `user_data.ps1` (PowerShell bootstrap to download & install PBIDesktopSetup_x64.exe silently)
- `outputs.tf` (instance_id, private_ip)
- `README.md` (step-by-step including SSM RDP tunnel and destroy)
- `.gitignore`

**Key implementation notes (cite docs inside comments):**
- Find the latest Windows Server 2022 AMI via `data "aws_ami"` with filters, owner `801119661308` and `most_recent=true`, avoiding hard-coded AMI IDs. (Terraform registry doc and examples for aws_ami filters.) [13](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)[14](https://www.turbogeek.co.uk/latest-ami-every-build/)
- Install Power BI Desktop silently with flags:  
  `-quiet -norestart ACCEPT_EULA=1 INSTALLDESKTOPSHORTCUT=0 DISABLE_UPDATE_NOTIFICATION=1`  
  (Installer options observed in deployment references and EXE parameters.) [15](https://www.appdeploynews.com/app-tips/microsoft-powerbi-desktop-2-130-754-0/)[16](https://blog.hametbenoit.info/2019/11/04/power-bi-the-new-exe-installer-command-lines/)
- Download URL for PBIDesktopSetup_x64.exe from Microsoft Download Center (monthly updates); keep it in `var.PBID_URL`. [17](https://www.microsoft.com/en-us/download/details.aspx?id=58494)[18](https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-get-the-desktop)
- Access over **SSM port-forwarded RDP** (no inbound 3389):  
  `aws ssm start-session --target <instance-id> --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=55678,portNumber=3389"`  
  Then open Windows App (RDP) to `localhost:55678`. (Official AWS knowledge center article.) [19](https://repost.aws/knowledge-center/systems-manager-session-manager-connect)

- Free Tier awareness: pick a Free Tier–eligible instance type and keep EBS at 30 GB; remind the user to destroy when done. [20](https://repost.aws/knowledge-center/free-tier-windows-instance)[21](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-eligibility.html)

- Best practice reminder in README: do **not** use the AWS root user daily; create an IAM admin and enable MFA. (AWS IAM root user best-practice.) [22](https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-best-practices.html)

**Generate full content for these files next.**

────────────────────────────────────────────────────────────────────────
C) HOW TO RUN (Copilot includes in README, but echo here too)
────────────────────────────────────────────────────────────────────────
1) Configure AWS CLI:
   - `aws configure` (use IAM admin keys, not root). (Official AWS CLI setup.) [6](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2) Deploy:
   - `terraform init && terraform apply -auto-approve`
   - Outputs will show the instance ID.

3) RDP via SSM port-forward:
   - `aws ssm start-session --target i-XXXXXXXX --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=55678,portNumber=3389"`  
     Then connect Windows App (RDP) to `localhost:55678`. [19](https://repost.aws/knowledge-center/systems-manager-session-manager-connect)

4) Destroy when done:
   - `terraform destroy -auto-approve` (Stay within Free Tier limits.) [21](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-eligibility.html)

────────────────────────────────────────────────────────────────────────
D) EXTRA (OPTIONAL)
────────────────────────────────────────────────────────────────────────
- Add a small **AWS Budgets** alert ($5) to catch surprise spend (document briefly).
- If you prefer **OpenTofu**, ensure the README shows `tofu init/plan/apply` equivalents. (Homebrew and project docs.) [2](https://opentofu.org/docs/intro/install/homebrew/)

Proceed to generate:
1) Repo tree
2) All files with complete content
