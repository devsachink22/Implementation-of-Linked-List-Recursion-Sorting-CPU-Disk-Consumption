import csv
import os
import time
import subprocess
import psutil

"""Node class for doubly linked list."""
class Node:
    def __init__(self, data=None):
        self.data = data
        self.prev = None
        self.next = None

"""Implementation of doubly linked list."""
class doubly_linked_list:
    def __init__(self):
        # head refers to the first node
        self.head = None
        # tail refers to the last node
        self.tail = None
        # size refers to the number of nodes
        self.size = 0
    
    """Append a node to the end of the list."""
    def add_node(self, data):
        new_node = Node(data)
        if self.head is None:
            self.head = new_node
            self.tail = new_node
        else:
            new_node.prev = self.tail
            self.tail.next = new_node
            self.tail = new_node
        self.size += 1
        return new_node
    
    """Return the node at the given index (0-based). Returns nothing if the index is invalid."""
    def remove_node(self, index):
        if index < 0 or index >= self.size:
            return False
        
        current = self.head
        for i in range(index):
            current = current.next
        
        if current.prev:
            current.prev.next = current.next
        else:
            self.head = current.next
        
        if current.next:
            current.next.prev = current.prev
        else:
            self.tail = current.prev
        
        self.size -= 1
        return True

    """Print all the nodes in the linked list."""
    def display_list(self):
        current = self.head
        while current:
            print(current.data)
            current = current.next

# Memory database built on a doubly linked list backed by CSV file.
class memory_database:
    def __init__(self, csv_file):
        self.csv_file = csv_file
        self.data_file = doubly_linked_list()
        self.last_modified_time = 0
        self.headers = None
        self.performance_logs = []
    
    """Recursive function to load CSV data into linked list."""
    def load_csv(self, rows, headers, index=0):
        if index >= len(rows):
            return
        
        # Create dictionary with headers as keys
        row_data={}
        for i, header in enumerate(headers):
            if i < len(rows[index]):
                row_data[header] = rows[index][i]
            else:
                row_data[header] = ""  # Handle missing values
        self.data_file.add_node(row_data)
        self.load_csv(rows, headers, index + 1)
    
    """Recursive function to load data from CSV file."""
    def load_data(self):
        try:
            with open(self.csv_file, 'r', newline='', encoding='utf-8') as file:
                reader = csv.reader(file)
                rows = list(reader)
                
                if not rows:
                    print("CSV file is empty")
                    return
                
                # first row = headers
                self.headers = rows[0]

                # Clear existing data
                self.data_file = doubly_linked_list()
                
                # Load data recursively
                if rows:
                    self.load_csv(rows[1:], self.headers)  # Skip header
                
                # Update last modified time
                self.last_modified_time = os.path.getmtime(self.csv_file)

                print(f"Successfully loaded {self.data_file.size} records from {self.csv_file}")
                
        except FileNotFoundError:
            print("CSV file not found")
        except Exception as e:
            print(f"Error loading CSV: {e}")
    
    """Recursively write linked list nodes to an open CSV file handle."""
    def export_csv(self, writer, node):
        if node is None:
            return
        row = [node.data.get(header, "") for header in self.headers]
        writer.writerow(row)
        self.export_csv(writer, node.next)
    
    """Export the linked list to a CSV file with headers and data."""
    def export_to_csv(self, output_file):
        if output_file is None:
            output_file = self.csv_file
        
        if self.headers is None:
            print("No data to export")
            return

        try:
            with open(output_file, 'w', newline='', encoding='utf-8') as file:
                writer = csv.writer(file)
                # Defined headers of python_result.csv file
                writer.writerow(self.headers)
                
                # Export data to python_result.csv file
                self.export_csv(writer, self.data_file.head)
            
            print(f"Exported {self.data_file.size} records to {output_file}")
            
        except Exception as e:
            print(f"Error exporting CSV: {e}")

    """Print the database contents with headers and row values."""
    def display_data(self):
        print("\nCurrent Memory Database Contents:")
        print(f"Total records: {self.data_file.size}")

        if self.headers:
            print(" | ".join(self.headers))
        
        current = self.data_file.head
        while current:
            row_data = current.data
            row_values = [str(row_data.get(header, "")) for header in self.headers]
            print(" | ".join(row_values))
            current = current.next

    """Check for the modification of underlying CSV."""
    def check_changes(self):
        print(f"Monitoring {self.csv_file} for changes... (Press Ctrl+C to stop)")
        while True:
            try:
                current_modified = os.path.getmtime(self.csv_file)
                if current_modified > self.last_modified_time:
                    print("CSV file changed. Reloading data.")
                    self.load_data()
                    return True
            except:
                pass
            return False
        
    """Continuously monitor the CSV file for changes at interval seconds. Reloads data if changes are detected."""
    def monitor_changes(self, interval=5):
        print(f"Monitoring {self.csv_file} for changes. (Press Ctrl+C to stop)")
        while True:
            try:
                self.check_changes()
                time.sleep(interval)
            except KeyboardInterrupt:
                print("Monitoring stopped")
                break
    """Prompt the user to enter values for each column header and append a new row to the linked list."""
    def add_row(self, row_data):
        if self.headers is None:
            print("No headers available. Load data first.")
            return
        
        newRow = []
        for i, header in enumerate(self.headers):
            value = input(f"Enter {header}: ")
            row_data.append(value)
        
            # Convert list to dictionary using headers
            dict_data = {}
            for i, header in enumerate(self.headers):
                if i < len(row_data):
                    dict_data[header] = row_data[i]
                else:
                    dict_data[header] = ""

        self.data_file.add_node(dict_data)
        self.export_to_csv("python_result.csv")
        print("Row added to memory database")
    
    """Prompt the user for a row index and remove that row from the database."""
    def remove_row(self, index):
        if self.data_file.size == 0:
            print("No records to remove.")
            return
        
        try:
            index = int(input(f"\nEnter row number to remove (0-{self.data_file.size-1}): "))
            if 0 <= index < self.data_file.size:
                # Show what will be removed
                current = self.data_file.head
                for i in range(index):
                    current = current.next
                row_data = current.data
                row_values = [str(row_data.get(header, "")) for header in self.headers]
                print(f"\nRecord to be removed: {' | '.join(row_values)}")
                
                confirm = input("Are you sure you want to remove this record? (y/n): ").lower()
                if confirm == 'y':
                    if self.data_file.remove_node(index):
                        self.export_to_csv("python_result.csv")
                        print("Record removed successfully.")
            else:
                print("Invalid row number.")
        except ValueError:
            print("Please enter a valid number.")

    """Recursive function to validate whether the specified column exist in headers or not."""
    def validate_key(self, key):
        if key not in self.headers:
            print(f"Error: Column '{key}' is not found in CSV headers.")
            print(f"Available Columns: {', '.join(self.headers)}")
            return False
        return True

    """Get current system resource usage"""
    def get_system_statistics(self):
        try:
            # CPU usage
            cpu_percent = psutil.cpu_percent(interval=0.1)
            
            # Memory usage
            memory = psutil.virtual_memory()
            memory_usage = memory.percent
            
            # Disk usage for current directory
            disk = psutil.disk_usage('.')
            disk_usage = disk.percent
            
            return {
                'cpu_percent': cpu_percent,
                'memory_percent': memory_usage,
                'disk_percent': disk_usage,
                'timestamp': time.time()
            }
        except Exception as e:
            print(f"Error getting system stats: {e}")
            return None

    """Run shell command and return output"""
    def run_shell_command(self, command):
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            return result.stdout.strip()
        except Exception as e:
            print(f"Error running command {command}: {e}")
            return ""

    """Measure performance of sorting algorithm"""
    def measure_sort_performance(self, sort_func, key, sort_name):
        print(f"\nMeasuring {sort_name} performance")
        
        # Get initial disk usage
        initial_disk = self.run_shell_command("du -sb . | cut -f1")
        
        # Get initial system stats
        initial_stats = self.get_system_statistics()
        
        # Start time
        start_time = time.time()
        
        # Execute the sort function
        sort_func(key)
        
        # End time
        end_time = time.time()
        
        # Get final system stats
        final_stats = self.get_system_statistics()
        
        # Get final disk usage
        final_disk = self.run_shell_command("du -sb . | cut -f1")
        
        # Calculate metrics
        execution_time = end_time - start_time
        
        performance_data = {
            'algorithm': sort_name,
            'execution_time': execution_time,
            'initial_disk_bytes': int(initial_disk) if initial_disk else 0,
            'final_disk_bytes': int(final_disk) if final_disk else 0,
            'disk_usage_change': (int(final_disk) - int(initial_disk)) if initial_disk and final_disk else 0,
            'initial_cpu': initial_stats['cpu_percent'] if initial_stats else 0,
            'final_cpu': final_stats['cpu_percent'] if final_stats else 0,
            'cpu_usage_change': (final_stats['cpu_percent'] - initial_stats['cpu_percent']) if initial_stats and final_stats else 0,
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
        }
        
        self.performance_logs.append(performance_data)
        return performance_data


    """Recursive function to implement the bubble sort for the linked list."""
    def bubble_sort(self, key):
        if not self.validate_key(key):
            return False
        if self.data_file.size <= 1:
            print("Not enough data to sort.")
            return True
        # Convert linked list to array for easier sorting
        nodes = []
        current = self.data_file.head
        while current:
            nodes.append(current)
            current = current.next
        # Bubble sort algorithm
        n = len(nodes)
        for i in range(0,n-1):
            swapped = False
            for j in range(0, n-i-1):
                # Handle missing keys by treating them as empty strings
                value1 = nodes[j].data.get(key, "")
                value2 = nodes[j+1].data.get(key, "")
                # Try to convert to numeric for proper comparison
                try:
                    value1 = float(value1) if value1 else 0
                    value2 = float(value2) if value2 else 0
                except ValueError:
                    # If conversion fails to numeric, compare as strings
                    pass
                if value1 > value2:
                    # Swap nodes by swapping their data
                    nodes[j].data, nodes[j+1].data = nodes[j+1].data, nodes[j].data
                    swapped = True
            if not swapped:
                break   
        print(f"Bubble sort is implemeted on column: {key}")
        
    """Recursive function to implement the insertion sort for the linked list."""
    def insertion_sort(self, key):
        if not self.validate_key(key):
            return False
        if self.data_file.size <= 1:
            print("Not enough data to sort.")
            return True
        current = self.data_file.head  # Start from first node
        while current:
            current_data = current.data
            # Identify the correct position for current node
            prev_node = current.prev
            while prev_node is not None:
                # Handle missing keys by treating them as empty strings
                prev_value = prev_node.data.get(key, "")
                current_value = current_data.get(key, "")
                # Try to convert to numeric for proper comparison
                try:
                    prev_value = float(prev_value) if prev_value else 0
                    current_value = float(current_value) if current_value else 0
                except ValueError:
                    # If conversion fails to numeric, compare as strings
                    pass
                if prev_value > current_value:
                    # Shift node to the right
                    prev_node.next.data, prev_node.data = prev_node.data, prev_node.next.data
                    prev_node = prev_node.prev
                else:
                    break
            if prev_node is None:
                # Update head if required
                self.data_file.head.data, current.data = current.data, self.data_file.head.data
            current = current.next
        print(f"Insertion sort is implemented on column: {key}")

    """Recursive function to opt a column from header for implementing the sorting algorithm."""
    def choose_sort_key(self):
        if not self.headers:
            print("No data is available. Please load the data first.")
            return None
        print(f"\nAvailable columns: {', '.join(self.headers)}")
        key = input("Enter a column name to sort: ").strip()
        if key not in self.headers:
            print(f"Error: '{key}' is not a valid column name.")
            return None
        return key
    
    """Function that gives the options of sorting algorithm to implement."""
    def opt_sorting_algorithm(self):
        print("\nChoose sorting algorithm for implementation in memory database")
        print("1. Bubble Sort")
        print("2. Insertion Sort")
        print("3. Compare Both Algorithms (Computational Performance)")
        print("Enter your choice (1, 2 or 3): ")
        algorithm_choice = input().strip()
        if algorithm_choice == "1":
            return "bubble"
        elif algorithm_choice == "2":
            return "insertion"
        elif algorithm_choice == "3":
            return "compare"
        else:
            print("Invalid choice. Using Bubble Sort as default.")
            return "bubble"
        
    """Recursive function to export the sorted data to CSV."""
    def export_sorted_csv(self, output_file, sort_type, key=None):
        if key is None:
            key = self.choose_sort_key()
            if key is None:
                return False
        if not self.validate_key(key):
            return False
        if sort_type == "bubble":
            self.bubble_sort(key)
        elif sort_type == "insertion":
            self.insertion_sort(key)
        else:
            print("Sort type is invalid. Please use bubble/insertion sort.")
            return
        self.export_to_csv(output_file)
        print(f"Sorted data exported to {output_file} using {sort_type} sort on column: {key}")

    """Compare performance of both sorting algorithms"""
    def compare_sorting_algorithms(self):
        if not self.headers:
            print("No data available. Load data first.")
            return
        
        key = self.choose_sort_key()
        if key is None:
            return
        
        print("\n=== Starting Performance Comparison ===")
        
        # Create a copy of the data for fair comparison
        original_nodes = []
        current = self.data_file.head
        while current:
            original_nodes.append(current.data.copy())
            current = current.next
        
        # Test Bubble Sort
        self.load_data()  # Reload original data
        bubble_perf = self.measure_sort_performance(self.bubble_sort, key, "Bubble Sort")
        
        # Restore original data for insertion sort test
        self.data_file = doubly_linked_list()
        for node_data in original_nodes:
            self.data_file.add_node(node_data)
        
        # Test Insertion Sort
        insertion_perf = self.measure_sort_performance(self.insertion_sort, key, "Insertion Sort")
        
        # Display comparison results
        self.display_performance_comparison(bubble_perf, insertion_perf)
        
        # Save performance logs to file
        self.save_performance_logs()

    """Display performance comparison results"""
    def display_performance_comparison(self, bubble_perf, insertion_perf):
        print("Performance Comparison Result")
        
        print(f"\n{'Metric':<25} {'Bubble Sort':<15} {'Insertion Sort':<15} {'Winner':<10}")
        
        # Execution Time
        bubble_time = bubble_perf['execution_time']
        insertion_time = insertion_perf['execution_time']
        time_winner = "Bubble" if bubble_time < insertion_time else "Insertion"
        print(f"{'Execution Time (s)':<25} {bubble_time:<15.4f} {insertion_time:<15.4f} {time_winner:<10}")
        
        # CPU Usage Change
        bubble_cpu = bubble_perf['cpu_usage_change']
        insertion_cpu = insertion_perf['cpu_usage_change']
        cpu_winner = "Bubble" if abs(bubble_cpu) < abs(insertion_cpu) else "Insertion"
        print(f"{'CPU Usage Change (%)':<25} {bubble_cpu:<15.2f} {insertion_cpu:<15.2f} {cpu_winner:<10}")
        
        # Disk Usage Change
        bubble_disk = bubble_perf['disk_usage_change']
        insertion_disk = insertion_perf['disk_usage_change']
        disk_winner = "Bubble" if bubble_disk < insertion_disk else "Insertion"
        print(f"{'Disk Usage Change (bytes)':<25} {bubble_disk:<15} {insertion_disk:<15} {disk_winner:<10}")

    """Save performance logs to CSV file"""
    def save_performance_logs(self):
        if not self.performance_logs:
            return
        
        log_file = "python_sorting_performance_logs.txt"
        fieldnames = ['timestamp', 'algorithm', 'execution_time', 'initial_disk_bytes', 
                     'final_disk_bytes', 'disk_usage_change', 'initial_cpu', 'final_cpu', 'cpu_usage_change']
        
        try:
            file_exists = os.path.isfile(log_file)
            with open(log_file, 'a', newline='', encoding='utf-8') as file:
                writer = csv.DictWriter(file, fieldnames=fieldnames)
                if not file_exists:
                    writer.writeheader()
                writer.writerows(self.performance_logs)
            print(f"\nPerformance logs saved to {log_file}")
        except Exception as e:
            print(f"Error saving performance logs: {e}")

    """Generate shell script for system monitoring"""
    def generate_monitoring_script(self):
        script_content = ""
        
        try:
            with open("monitor_resources.sh", "w") as f:
                f.write(script_content)
            os.chmod("monitor_resources.sh", 0o755)
            print("Monitoring script generated: monitor_resources.sh")
        except Exception as e:
            print(f"Error generating monitoring script: {e}")


# Main Execution
if __name__ == "__main__":
    # Initialize the memory database
    db = memory_database("student-data.csv")
    
    # Load initial data
    db.load_data()

    # Display loaded data
    db.display_data()
    
    # Export to new CSV
    db.export_to_csv("python_result.csv")

    # Generate monitoring script
    db.generate_monitoring_script()

    # Ask user to choose a sorting algorithm
    opt_type = db.opt_sorting_algorithm()
    if opt_type == "bubble":
        # Sort and export the nodes using bubble sort
        db.export_sorted_csv("python_bubble_sorted.csv", "bubble")
    elif opt_type == "insertion":
        # Sort and export the nodes using insertion sort  
        db.export_sorted_csv("python_insertion_sorted.csv", "insertion")
    elif opt_type == "compare":
        # Compare both algorithms
        db.compare_sorting_algorithms()

    # Monitors real time changes in student-data.csv file.
    # db.monitor_changes()

    # Insert a new row in result file.
    # db.add_row([])

    # Remove a particular row from result file.
    # db.remove_row([])