@lazyglobal off.

parameter input_path, output_path.


function main {
    local input_file to open(input_path).
    local output_file to create(output_path).

    
}

if exists(output_path) {
    print("Output path already exists. Exiting.").
} else if (not exists(input_path)) {
    print("Input path does not exist. Exiting.").
} else {
    main().
}