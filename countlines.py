import os

# load filesnames from all files and directories in lib folder
files = os.listdir('lib')

# recursive function to count lines in all files in all folders
def countlines(files, path):
    total = 0
    for file in files:
        if os.path.isdir(path + '/' + file):
            total += countlines(os.listdir(path + '/' + file), path + '/' + file)
        else:
            with open(path + '/' + file, 'r') as f:
                lines_in_file = len(f.readlines())
                print(f'{file}: {lines_in_file}')
                total += lines_in_file
    return total

# count line for all files in lib folder
print(countlines(files, 'lib'))