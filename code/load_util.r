add_vm_jdk_from_name_version_configuration <- function (data, name_file) {

    # Virtual machine performance is associated with name, version, and configuration.
    columns <- c ('vm_name', 'vm_version', 'vm_configuration')
    combinations <- distinct (data, vm_name, vm_version, vm_configuration)

    # Fetch virtual machine name file if any.
    if (file.exists (name_file)) {
        name_data <- read_csv (name_file, col_types = cols (jdk = col_integer (), .default = col_factor ()))
        name_left <- anti_join_with_factor_merger (combinations, name_data, columns)
    } else {
        name_data <- tibble ()
        name_left <- combinations
    }

    # Compute hashes for whatever leftover combinations are there and save complete data.
    if (nrow (name_left) > 0) {
        pwalk (name_left, function (vm_name, vm_version, vm_configuration) log_warn ('Missing virtual machine name for "{vm_name}", "{vm_version}", "{vm_configuration}".'))
        digest_vector <- Vectorize (digest, c ('object'))
        name_left <- mutate (name_left, vm = digest_vector (paste (vm_name, vm_version, vm_configuration), algo = 'murmur32'), jdk = as.integer (0))
        name_data <- bind_rows (name_data, name_left)
        # Move the VM and JDK columns to the front for easy CSV edit.
        name_data <- relocate (name_data, vm, jdk)
        write_csv (name_data, name_file)
    }

    # Annotate performance with virtual machine.
    result <- left_join_with_factor_merger (data, name_data, columns)

    return (result)
}
