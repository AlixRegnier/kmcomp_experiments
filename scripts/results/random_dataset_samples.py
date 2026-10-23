import sys
from pathlib import Path
from typing import List
from random import sample, randint
from multiprocessing import Pool

if len(sys.argv) <= 1 or len(sys.argv) > 4:
    print("Usage: sample_dataset_sequences <dir> <size> [n=1]")
    exit(2)

path = sys.argv[1]
seq_size = int(sys.argv[2])

n = 1
if len(sys.argv) == 4:
    n = int(sys.argv[3])

def list_files(path : str, ext : List[str]):
    files = []

    def __recurse(subpath : Path):
        p = Path(subpath)
        for entry in p.iterdir():
            if entry.is_dir(follow_symlinks=False):
                __recurse(entry)
            elif entry.is_file() and entry.suffix in ext:
                files.append(str(entry))

    __recurse(path)
    return files

class SeqLoc:
    def __init__(self, file : str, begin=None, end=None):
        self.file = file
        self.size = 0
        self.begin = begin
        self.end = end
        self.id = None

        if begin is not None and end is not None and begin > end:
            raise

    def read_from_fd(self, fd) -> str:
        fd.seek(self.begin)
        return fd.read(self.end - self.begin).replace("\n", "").strip()

    def read(self) -> str:
        with open(self.file, "r") as f:
            return self.read_from_fd(f)

def index_sequences(path : str):
    subsequences_indices = []

    with open(path, "r") as f:
        current_pos = 0
        for line in f:
            current_pos += len(line)
            if line.startswith(">"):
                if len(subsequences_indices) > 0:
                    subsequences_indices[-1].end = current_pos - len(line)
                subsequences_indices.append(SeqLoc(path, begin=current_pos))

        if len(subsequences_indices) > 0:
            subsequences_indices[-1].end = current_pos-1 #Add EOF position

        for s in subsequences_indices:
            s.size = len(s.read_from_fd(f))
    return subsequences_indices

#List fasta files in subdirectories
files = list_files(path, [".fna",".fa",".fasta"])

#Locate sequences in fasta files
seqs = []


def process_seq(seq : SeqLoc):
    with open(f"seq_{seq.id}.fasta", "w") as out_fasta:
        out_fasta.write(f">sampled_seq_{seq.id}\n")
        s = seq.read()
        #Select a random window of 'seq_size' nucleotides
        s = s[seq.size - seq_size - randint(0, seq.size - seq_size):][:seq_size]
        out_fasta.write(f"{s}\n")

with Pool() as p:
    seqs = [seq for locs in p.map(index_sequences, files) for seq in locs]

    before_nb_seqs = len(seqs)

    #Filter out all sequences that do not contain big enough sequences
    i = 0
    while i < len(seqs):
        if seqs[i].size < seq_size:
            del seqs[i]
        else:
            i += 1

    nb_remaining_files = len({seq.file for seq in seqs})

    print(f"Nb sequences after size filtering: {len(seqs)}/{before_nb_seqs}")
    print(f"Nb FASTA files after size filtering: {nb_remaining_files}/{len(files)}")

    if len(seqs) == 0:
        raise Exception("[ERROR] Insufficient number of sequences")

    if len(seqs) < n:
        X = ((n + len(seqs) - 1) // len(seqs) - 1)
        print(f"[WARNING] As the number of filtered sequences is below the number of requested sequence, sequences from which are sampled subsequences will be cloned (x{X})")
        x = seqs[:]

        for _ in range(X):
            seqs.extend(x)

    seqs = sorted(sample(seqs, n), key=lambda x: x.file)

    #Give id
    for i in range(len(seqs)):
        seqs[i].id = i
        print(seqs[i].size)

    p.map(process_seq, seqs)

