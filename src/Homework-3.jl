using CSV
using DataFrames
using Dates
import Statistics

# Performance measurement structure
mutable struct performance_metrics
    algorithm::String
    execution_time::Float64
    cpu_usage::Float64
    memory_usage::Float64
    disk_space_usage::Int64
    timestamp::String
end

# Node definition for singly linked list.
mutable struct Node
    """A node in a singly linked list, storing a dictionary of key-value pairs and a reference to the next node."""
    data::Dict{String, String}
    next::Union{Node, Nothing}
    function Node(data::Dict{String, String})
        new(data, nothing)
    end
end

# Implementation of singly linked list.
mutable struct singly_linked_list
    # head refers to the first node
    head::Union{Node, Nothing}
    # tail refers to the last node
    tail::Union{Node, Nothing}
    # size refers to the number of nodes
    size::Int
    function singly_linked_list()
        new(nothing, nothing, 0)
    end
end

# Append a node to the last of the list.
function add_node(list::singly_linked_list, data::Dict{String, String})
    new_node = Node(data)
    if list.head === nothing
        list.head = new_node
        list.tail = new_node
    else
        list.tail.next = new_node
        list.tail = new_node
    end
    list.size += 1
    return new_node
end

# Remove a node at the specific index.
function remove_node(list::singly_linked_list, index::Int)
    if index < 0 || index >= list.size
        return false
    end
    if index == 0
        list.head = list.head.next
        if list.head === nothing
            list.tail = nothing
        end
        list.size -= 1
        return true
    end
    current = list.head
    for _ in 1:(index - 1)
        current = current.next
    end
    current.next = current.next.next
    if current.next === nothing
        list.tail = current
    end
    list.size -= 1
    return true
end

"""Return the node at the given index (0-based). Returns nothing if the index is invalid."""
function get_node_at(list::singly_linked_list, index::Int)
    if index < 0 || index >= list.size
        return nothing
    end
    current = list.head
    for _ in 1:index
        current = current.next
    end
    return current
end

# Print all the nodes in the linked list.
function display_list(list::singly_linked_list)
    current = list.head
    while current !== nothing
        println(current.data)
        current = current.next
    end
end

# Memory database built on a singly linked list backed by CSV file.
mutable struct memory_database
    csv_file::String
    data_list::singly_linked_list
    last_modified_time::Float64
    headers::Vector{String}
    performance_logs::Vector{performance_metrics}
    function memory_database(csv_file::String)
        new(csv_file, singly_linked_list(), 0.0, String[], performance_metrics[])
    end
end

# Recursive function to load CSV data into linked list.
function load_csv(db::memory_database, rows::Vector{Vector{String}}, index::Int)
    if index > length(rows)
        return
    end

    row = rows[index]
    # Create dictionary with headers as keys.
    row_data = Dict{String,String}()
    for (i, h) in enumerate(db.headers)
        if i <= length(row)
            row_data[h] = row[i]
        else
            row_data[h] = ""
        end
    end
    add_node(db.data_list, row_data)
    load_csv(db, rows, index + 1)
end

# Recursive function to load data from CSV file.
function load_data(db::memory_database)
    if !isfile(db.csv_file)
        println("CSV file not found: ", db.csv_file)
        return
    end
    rows = CSV.File(db.csv_file; header=false) |> collect
    if isempty(rows)
        println("CSV file is empty")
        return
    end

    # first row = headers
    db.headers = [string(x) for x in rows[1]]
    data_rows = [Vector{String}(string.(row)) for row in rows[2:end]]

    db.data_list = singly_linked_list()
    if !isempty(data_rows)
        load_csv(db, data_rows, 1)
    end

    db.last_modified_time = stat(db.csv_file).mtime
    println("Successfully loaded $(db.data_list.size) records from $(db.csv_file)")
end

# Recursively write linked list nodes to an open CSV file handle.
function export_csv(io::IO, node::Union{Node,Nothing}, headers::Vector{String})
    if node === nothing
        return
    end
    row = [get(node.data, h, "") for h in headers]
    println(io, join(row, ","))
    export_csv(io, node.next, headers)
end

# Export the linked list to a CSV file with headers and data.
function export_to_csv(db::memory_database, output_file::String="julia_result.csv")
    if isempty(db.headers)
        println("No data to export")
        return
    end
    open(output_file, "w") do io
        println(io, join(db.headers, ","))
        export_csv(io, db.data_list.head, db.headers)
    end
    println("Exported $(db.data_list.size) records to $output_file")
end

# Print the database contents with headers and row values.
function display_data(db::memory_database)
    println("\nCurrent Memory Database Contents:")
    println("Total records: ", db.data_list.size)
    if !isempty(db.headers)
        println(join(db.headers, " | "))
    end
    current = db.data_list.head
    while current !== nothing
        row_data = current.data
        row_values = [get(current.data, h, "") for h in db.headers]
        println(join(row_values, " | "))
        current = current.next
    end
end

# Check for the modification of underlying CSV.
function check_changes(db::memory_database)
    if !isfile(db.csv_file)
        return false
    end
    current_modified = stat(db.csv_file).mtime
    if current_modified > db.last_modified_time
        println("CSV file changed. Reloading data.")
        load_data(db)
        export_to_csv(db, "julia_result.csv")
        return true
    end
    return false
end

"""Continuously monitor the CSV file for changes at interval seconds. Reloads data if changes are detected."""
function monitor_changes(db::memory_database, interval::Int)
    println("Monitoring $(db.csv_file) for changes. (Ctrl+C to stop)")
    while true
        check_changes(db)
        sleep(interval)
    end
end

# Prompt the user to enter values for each column header and append a new row to the linked list.
function add_row(db::memory_database)
    if isempty(db.headers)
        println("No headers available. Load data first.")
        return
    end
    row_data = Dict{String,String}()
    for h in db.headers
        print("Enter $h: ")
        value = readline()
        row_data[h] = value
    end
    add_node(db.data_list, row_data)
    export_to_csv(db, "julia_result.csv")
    println("Row added to memory database")
end

# Prompt the user for a row index and remove that row from the database.
function remove_row(db::memory_database)
    if db.data_list.size == 0
        println("No records to remove.")
        return
    end
    print("Enter row number to remove (0-$(db.data_list.size-1)): ")
    index = parse(Int, readline())
    if index < 0 || index >= db.data_list.size
        println("Invalid row number.")
        return
    end
    row_data = get_node_at(db.data_list, index)
    row_values = [get(row_data.data, header, "") for header in db.headers]
    println("Record to be removed: ", join(row_values, " | "))
    print("Are you sure you want to remove this record? (y/n): ")
    confirm = lowercase(readline())
    if confirm == "y"
        if remove_node(db.data_list, index)
            export_to_csv(db, "julia_result.csv")
            println("Record removed successfully.")
        end
    end
end
# Recursive function to validate whether the specified column exist in headers or not.
function validate_key(db::memory_database, key::AbstractString)
    if db.headers === nothing || !(String(key) in db.headers)
        println("Error: Column '$key' is not found in CSV headers.")
        if db.headers !== nothing
            println("Available Columns: $(join(db.headers, ", "))")
        end
        return false
    end
    return true
end

# Get current system resource usage
function get_system_statistics()
    try
        # Get memory usage
        memory_info = Sys.free_memory()
        total_memory = Sys.total_memory()
        memory_usage = ((total_memory - memory_info) / total_memory) * 100
        
        # Get disk usage for current directory
        disk_info = stat(".")
        disk_usage = disk_info.size
        
        return (memory_usage = round(memory_usage, digits=2), disk_usage = disk_usage)
    catch e
        println("Error getting system stats: $e")
        return (memory_usage = 0.0, disk_usage = 0)
    end
end

# Measure performance of sorting algorithm
function measure_sort_performance(db::memory_database, sort_func::Function, key::String, sort_name::String)
    println("Measuring $sort_name performance")
    
    # Get initial disk usage
    initial_stats = get_system_statistics()
    initial_disk = initial_stats.disk_usage
    
    # Start time
    start_time = time()
    
    # Execute the sort function
    sort_func(db, key)
    
    # End time
    end_time = time()
    
    # Get final system stats
    final_stats = get_system_statistics()
    final_disk = final_stats.disk_usage
    
    # Calculate metrics
    execution_time = end_time - start_time
    
    performance_data = performance_metrics(
        sort_name,
        execution_time,
        initial_stats.memory_usage,  # Using memory as proxy for CPU in this simplified version
        final_stats.memory_usage,
        final_disk - initial_disk,
        string(now())
    )
    
    push!(db.performance_logs, performance_data)
    return performance_data
end

# Recursive function to implement the bubble sort for the linked list.
function bubble_sort(db::memory_database, key::String)
    if !validate_key(db, String(key))
        return false
    end
    if db.data_list.size <= 1
        println("Not enough data to sort.")
        return true
    end
    # Convert linked list to array for easier sorting
    nodes = Node[]
    current = db.data_list.head
    while current !== nothing
        push!(nodes, current)
        current = current.next
    end
    # Bubble sort algorithm
    n = length(nodes)
    for i in 1:n-1
        swapped = false
        for j in 1:n-i
            # Handle missing keys by treating them as empty strings
            value1 = get(nodes[j].data, key, "")
            value2 = get(nodes[j+1].data, key, "")
            # Try to convert to numeric for proper comparison
            try
                val1 = isempty(value1) ? 0.0 : parse(Float64, value1)
                val2 = isempty(value2) ? 0.0 : parse(Float64, value2)
                if val1 > val2
                    nodes[j].data, nodes[j+1].data = nodes[j+1].data, nodes[j].data
                    swapped = true
                end
            catch
                # If conversion fails to numeric, compare as strings
                if value1 > value2
                    nodes[j].data, nodes[j+1].data = nodes[j+1].data, nodes[j].data
                    swapped = true
                end
            end
        end
        if !swapped
            break
        end
    end
    println("Bubble sort is implemented on column: $key")
    return true
end

# Recursive function to implement the insertion sort for the linked list.
function insertion_sort(db::memory_database, key::String)
    if !validate_key(db, String(key))
        return false
    end
    if db.data_list.size <= 1
        println("Not enough data to sort.")
        return true
    end
    # Convert to array for sorting as we are using a singly linked list
    nodes = Node[]
    current = db.data_list.head
    while current !== nothing
        push!(nodes, current)
        current = current.next
    end
    # Insertion sort algorithm
    for i in 2:length(nodes)
        j = i
        while j > 1
            value1 = get(nodes[j-1].data, key, "")
            value2 = get(nodes[j].data, key, "")
            # Try to convert to numeric for proper comparison
            try
                val1 = isempty(value1) ? 0.0 : parse(Float64, value1)
                val2 = isempty(value2) ? 0.0 : parse(Float64, value2)
                if val1 > val2
                    nodes[j-1].data, nodes[j].data = nodes[j].data, nodes[j-1].data
                    j -= 1
                else
                    break
                end
            catch
                # If conversion fails to numeric, compare as strings
                if value1 > value2
                    nodes[j-1].data, nodes[j].data = nodes[j].data, nodes[j-1].data
                    j -= 1
                else
                    break
                end
            end
        end
    end
    println("Insertion sort is implemented on column: $key")
    return true
end

# Recursive function to choose a column from header for implementing the sorting algorithm.
function choose_sort_key(db::memory_database)
    if isempty(db.headers)
        println("No data is available. Please load the data first.")
        return nothing
    end
    println("\nAvailable columns: $(join(db.headers, ", "))")
    print("Enter a column name to sort: ")
    key_input = readline()
    key = string(strip(key_input))  # Convert to String explicitly
    
    if !(key in db.headers)
        println("Error: '$key' is not a valid column name.")
        return nothing
    end
    return key
end

# Function that gives the options of sorting algorithm to implement.
function opt_sorting_algorithm()
    println("\nChoose sorting algorithm for implementation in memory database:")
    println("1. Bubble Sort")
    println("2. Insertion Sort")
    println("3. Compare Both Algorithms (Computational Performance)")
    print("Enter your choice (1, 2, or 3): ")
    algorithm_choice = strip(readline())
    if algorithm_choice == "1"
        return "bubble"
    elseif algorithm_choice == "2"
        return "insertion"
    elseif algorithm_choice == "3"
        return "compare"
    else
        println("Invalid choice. Using Bubble Sort as default.")
        return "bubble"
    end
end

# Recursive function to export the sorted data to CSV.
function export_sorted_csv(db::memory_database, output_file::String, sort_type::String, key::Union{String, Nothing}=nothing)
    if key === nothing
        key = choose_sort_key(db)
        if key === nothing
            return false
        end
    end
    if !validate_key(db, key)
        return false
    end
    if sort_type == "bubble"
        bubble_sort(db, String(key))
    elseif sort_type == "insertion"
        insertion_sort(db, String(key))
    else
        println("Sort type is invalid. Please use bubble/insertion sort.")
        return
    end
    export_to_csv(db, output_file)
    println("Sorted data exported to $output_file using $sort_type sort on column: $key")
    return true
end

# Compare performance of both sorting algorithms
function compare_sorting_algorithms(db::memory_database)
    if isempty(db.headers)
        println("No data available. Load data first.")
        return
    end
    
    key = choose_sort_key(db)
    if key === nothing
        return
    end
    
    println("\n=== Starting Performance Comparison ===")
    
    # Create a copy of the data for fair comparison
    original_nodes = Dict{String, String}[]
    current = db.data_list.head
    while current !== nothing
        push!(original_nodes, copy(current.data))
        current = current.next
    end
    
    # Test Bubble Sort
    load_data(db)  # Reload original data
    bubble_perf = measure_sort_performance(db, bubble_sort, key, "Bubble Sort")
    
    # Restore original data for insertion sort test
    db.data_list = singly_linked_list()
    for node_data in original_nodes
        add_node(db.data_list, node_data)
    end
    
    # Test Insertion Sort
    insertion_perf = measure_sort_performance(db, insertion_sort, key, "Insertion Sort")
    
    # Display comparison results
    display_performance_comparison(bubble_perf, insertion_perf)
    
    # Save performance logs to file
    save_performance_logs(db)
end

# Display performance comparison results
function display_performance_comparison(bubble_perf::performance_metrics, insertion_perf::performance_metrics)
    println("Performance Comparison Test")
    
    println("\n$(lpad("Metric", 25)) $(lpad("Bubble Sort", 15)) $(lpad("Insertion Sort", 15)) $(lpad("Winner", 10))")
    
    # Execution Time
    bubble_time = bubble_perf.execution_time
    insertion_time = insertion_perf.execution_time
    time_winner = bubble_time < insertion_time ? "Bubble" : "Insertion"
    println("$(lpad("Execution Time (s)", 25)) $(lpad(round(bubble_time, digits=4), 15)) $(lpad(round(insertion_time, digits=4), 15)) $(lpad(time_winner, 10))")
    
    # Memory Usage
    bubble_memory = bubble_perf.cpu_usage
    insertion_memory = insertion_perf.cpu_usage
    memory_winner = abs(bubble_memory) < abs(insertion_memory) ? "Bubble" : "Insertion"
    println("$(lpad("Memory Usage (%)", 25)) $(lpad(round(bubble_memory, digits=2), 15)) $(lpad(round(insertion_memory, digits=2), 15)) $(lpad(memory_winner, 10))")
    
    # Disk Usage Change
    bubble_disk = bubble_perf.disk_space_usage
    insertion_disk = insertion_perf.disk_space_usage
    disk_winner = bubble_disk < insertion_disk ? "Bubble" : "Insertion"
    println("$(lpad("Disk Usage Change (bytes)", 25)) $(lpad(bubble_disk, 15)) $(lpad(insertion_disk, 15)) $(lpad(disk_winner, 10))")
end

# Save performance logs to CSV file
function save_performance_logs(db::memory_database)
    if isempty(db.performance_logs)
        return
    end
    
    log_file = "julia_sorting_performance_logs.txt"
    try
        # Create DataFrame from performance logs
        df = DataFrame(
            timestamp = [log.timestamp for log in db.performance_logs],
            algorithm = [log.algorithm for log in db.performance_logs],
            execution_time = [log.execution_time for log in db.performance_logs],
            memory_usage = [log.cpu_usage for log in db.performance_logs],
            disk_space_usage = [log.disk_space_usage for log in db.performance_logs]
        )
        CSV.write(log_file, df)
        println("\nPerformance logs saved to $log_file")
    catch e
        println("Error saving performance logs: $e")
    end
end

# Generate shell script for system monitoring
function generate_monitoring_script()
    script_content =
    
    try
        open("julia_monitor_resources.sh", "w") do file
            write(file, script_content)
        end
        # Make the script executable (Unix/Linux/Mac)
        run(`chmod +x julia_monitor_resources.sh`)
        println("Monitoring script generated: julia_monitor_resources.sh")
    catch e
        println("Error generating monitoring script: $e")
    end
end

# Main Execution
function main()
    # Initialize the memory database
    db = memory_database("student-data.csv")

    # Load initial data
    load_data(db)

    # Display loaded data
    display_data(db)

    # Export to new CSV
    export_to_csv(db, "julia_result.csv")

    # Generate monitoring script
    generate_monitoring_script()
    # Ask user to choose a sorting algorithm
    sort_type = opt_sorting_algorithm()
    if sort_type == "bubble"
        # Sort and export the nodes using bubble sort
        export_sorted_csv(db, "julia_bubble_sorted.csv", "bubble")
    elseif sort_type == "insertion"
        # Sort and export the nodes using insertion sort  
        export_sorted_csv(db, "julia_insertion_sorted.csv", "insertion")
    elseif sort_type == "compare"
        # Compare both algorithms
        compare_sorting_algorithms(db)
    end
    # Monitors real time changes in student-data.csv file
    # monitor_changes(db, 5)

    # Insert a new row in result file
    # add_row(db)

    # Remove a particular row from result file
    # remove_row(db)
end
main()