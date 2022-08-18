# Take meta.id and file. All files are assumed CDNA.
# Script is adapted from my own used for data cleaning at Sanger
import sys
import os

def read_fasta(filetoparse):
    """
    A function which opens and splits a fasta into name and seq.
    :param filetoparse:
    """
    counter = 0
    name, seq = None, []

    for line in filetoparse:
        line = line.rstrip()

        if line.startswith(">"):
            if name:
                yield name, ''.join(seq)
            name, seq = line, []
        else:
            seq.append(line)

    if name:
        yield name, ''.join(seq)
        counter += 1

def entry_function(entry_per: int, file: str, id):
    count = 0
    entry = []
    file_count = 0
    if os.path.exists(file):
        with open(file, 'r') as for_parsing:
            for name, seq in read_fasta(for_parsing):
                count += 1
                name_seq = name, seq
                entry.append(name_seq)
                if int(count) == int(entry_per):
                    file_count += 1
                    print(f'Filling file: {file_count} w/ {count}')
                    with open(f'{id}_{file_count}.MOD.fa', 'w') as end_file:
                        for header, seq in entry:
                            end_file.write(f'{header}\n{seq}\n')
                        count = 0
                        entry = []

                file_count += 1 

            print(f'Filling file: {file_count} w/ {count}')
            with open(f'{id}_{count}.MOD.fa', 'w') as end_file:
                for header, seq in entry:
                    end_file.write(f'{header}\n{seq}\n')

                entry = [] 

def main():
    file = sys.argv[1]
    id = sys.argv[2]
    entry_per = sys.argv[3]

    entry_function(entry_per, file, id)


if __name__ == "__main__":
    main()