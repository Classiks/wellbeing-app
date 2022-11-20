import os

# load filesnames from all files and directories in lib folder
files = os.listdir('lib')

# recursive function to count lines in all files in all folders
def returnlines(files, path):
    lines = []
    for file in files:
        if os.path.isdir(path + '/' + file):
            lines += returnlines(os.listdir(path + '/' + file), path + '/' + file)
        else:
            with open(path + '/' + file, 'r') as f:
                for line in f.readlines():
                    lines.append(line)
    return lines

# write lines for all files in lib folder

with open('all_lines.txt', 'w') as f:
    for line in returnlines(files, 'lib'):
        f.write(line)
