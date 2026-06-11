# GCP Infrastructure Setup with Terraform

This is a **module-based Terraform project** that provisions Google Cloud Platform (GCP) infrastructure. It leverages a reusable Terraform module to create and manage a Compute Engine VM instance with configurable settings, while using Google Cloud Storage for remote state management.

## Project Structure

This is a **module-based architecture** where the compute module calls an external Terraform module:

```
gcp-infra-create/
├── compute/
│   ├── main.tf         # Main configuration (calls external module)
│   ├── variables.tf    # Variable definitions passed to module
│   ├── backend.tf      # Remote state configuration (GCS)
│   └── dev.tfvars      # Dev environment variables
└── README.md           # This file
```

### Architecture

- **Root Module:** `compute/` - Orchestrates infrastructure provisioning
- **External Module:** `https://github.com/mayursury59/terraform-modules.git` - Contains reusable VM resource definitions

## Prerequisites

- Terraform >= 1.0
- Google Cloud SDK CLI (`gcloud`)
- GCP Project with billing enabled
- Appropriate IAM permissions (Compute Admin, Storage Admin)

## Configuration

### 1. Set up GCP Project

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Create GCS Bucket for State

```bash
gsutil mb gs://tf-state-dev0000
```

### 3. Configure Variables

Edit `compute/dev.tfvars` with your values:

```hcl
project_id   = "your-gcp-project-id"
vm_name      = "my-vm"
machine_type = "e2-medium"
zone         = "us-central1-a"
```

### 4. Initialize Terraform

```bash
cd compute
terraform init
```

## Usage

### Plan Infrastructure

```bash
terraform plan -var-file="dev.tfvars"
```

### Apply Configuration

```bash
terraform apply -var-file="dev.tfvars"
```

### Destroy Infrastructure

```bash
terraform destroy -var-file="dev.tfvars"
```

## Variables

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `project_id` | string | Yes | GCP Project ID |
| `vm_name` | string | Yes | Name of the Compute Engine instance |
| `machine_type` | string | Yes | Machine type (e.g., `e2-medium`, `n1-standard-1`) |
| `zone` | string | Yes | GCP zone for the VM (e.g., `us-central1-a`) |

## Module-Based Design

This project follows Terraform best practices by using a **remote reusable module**:

### External Module Details
- **Source:** `https://github.com/mayursury59/terraform-modules.git`
- **Purpose:** Provides encapsulated VM resource definitions, validation, and best practices
- **Benefits:** 
  - Code reusability across projects
  - Centralized updates to infrastructure patterns
  - Separation of concerns between orchestration and implementation

### Central Module Repository Structure

The [terraform-modules](https://github.com/mayursury59/terraform-modules) repository serves as a **centralized module library** used across multiple infrastructure projects:

```
terraform-modules/
├── main.tf           # VM resource definitions and core infrastructure logic
├── output.tf         # Output values for VM attributes (IP, name, etc.)
└── variables.tf      # Input variable definitions for module customization
```

**Key Files:**
- **main.tf** - Contains the `google_compute_instance` resource and any supporting resources
- **variables.tf** - Defines input variables like `vm_name`, `machine_type`, `zone`, `tags`
- **output.tf** - Exposes outputs such as instance ID, internal/external IPs for consumption by other modules

### How It Works
The `compute/main.tf` file calls the external module and passes variables:
```hcl
module "vm" {
    source = "https://github.com/mayursury59/terraform-modules.git"
    
    vm_name      = var.vm_name
    machine_type = var.machine_type
    zone         = var.zone
    tags         = ["dev"]
}
```

This allows multiple infrastructure repositories to utilize the same VM module without duplicating code.

## Remote State

State is stored remotely in Google Cloud Storage:
- **Bucket:** `tf-state-dev0000`
- **Prefix:** `vm`

This enables team collaboration and prevents state drift.

## Outputs

After applying, Terraform will display:
- VM instance name
- Internal IP address
- External IP address (if assigned)

## Troubleshooting

### Authentication Issues
Ensure you're authenticated with GCP:
```bash
gcloud auth application-default login
```

### State Bucket Not Found
Verify the bucket exists:
```bash
gsutil ls gs://tf-state-dev0000
```

### Provider Version Issues
Update the Google provider:
```bash
terraform init -upgrade
```

## Security Considerations

- Store sensitive values (project IDs, credentials) in `.tfvars` files
- Add `.tfvars` to `.gitignore` to avoid committing secrets
- Use IAM roles with minimal required permissions
- Enable audit logging for infrastructure changes

## References

- [Terraform Google Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Terraform Remote State](https://www.terraform.io/language/state/remote)

## License

This project is provided as-is for infrastructure automation.
