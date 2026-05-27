from typing import Dict, List
from math import log10, floor
import json

#Constants
RAW_ECOLI = 17991315712
RAW_SENTERICA = 963993612544
RAW_HUMANGUT = 29671305472


def get_dict_from_json(filename : str) -> Dict[str,str]:
    with open(filename, "r") as f:
        return json.load(f)

def get_dict_from_delimited_file(filename : str, delimiter : str = "\t") -> Dict[str,str]:
    d = dict()
    with open(filename, "r") as f:
        for line in f:
            k, v = line.strip().split(delimiter)
            d[k] = v
    return d

def read_lines_from_file(filename : str) -> List[str]:
    with open(filename, "r") as f:
        return f.readlines()

def KMG_label(x : int) -> str:
    r = str(x)

    if x < 1000:
        r = str(int(x))
    
    if x >= 10**3 and x < 10**6:
        r = str(int(x//10**3)) + "K"
    
    if x >= 10**6 and x < 10**9:
        r = str(int(x//10**6)) + "M"
    
    if x >= 10**9:
        r = str(int(x//10**9)) + "G"
    
    return r

def KMB_label(x : int) -> str:
    r = str(x)

    if x < 1000:
        r = str(int(x))
    
    if x >= 10**3 and x < 10**6:
        r = str(int(x//10**3)) + "K"
    
    if x >= 10**6 and x < 10**9:
        r = str(int(x//10**6)) + "M"
    
    if x >= 10**9:
        r = str(int(x//10**9)) + "B"

    return r

def KMG_float_label(x : float) -> str:
    r = f"{x:.1f}"

    if x < 1000:
        r = str(int(x))
    
    if x >= 10**3 and x < 10**6:
        r = f"{x/10**3:.1f} K"
    
    if x >= 10**6 and x < 10**9:
        r = f"{x/10**6:.1f} M"
    
    if x >= 10**9:
        r = f"{x/10**9:.1f} G"
        
    return r

def KM_label(x : int) -> str:
    r = str(x)

    if x < 1000:
        r = str(int(x))
    
    if x >= 10**3 and x < 10**6:
        r = str(int(x//10**3)) + "K"
    
    if x >= 10**6:
        r = str(int(x//10**6)) + "M"
    
    return r

def scientific_float(x : int) -> str:
    if x == 0:
        return "0"
    
    exp = int(floor(log10(x)))

    return f"{x / 10 ** exp:.2f}e{exp}"

def scientific_int(x : int) -> str:
    if x == 0:
        return "0"
    
    exp = int(floor(log10(x)))

    return f"{int(x // 10 ** exp)}e{exp}"

def KMG_pow2(x : float) -> str:
    x = round(x)
    r = f"{int(x)}"

    if x < 1024:
        r = str(int(x))
    
    if x >= 2**10 and x < 2**20:
        r = f"{int(x//2**10)} KB"
    
    if x >= 2**20 and x < 2**30:
        r = f"{int(x//2**20)} MB"
    
    if x >= 2**30:
        r = f"{int(x//2**30)} GB"

    return r

def MEGA_label(x : int) -> str:
    return f"{int(x // 1024 ** 2)} MB"

def GIGA_label(x : int) -> str:
    return f"{int(x // 1024 ** 3)} GB"

def TERA_label(x : int) -> str:
    return f"{int(x // 1024 ** 4)} TB"

def time_label(seconds : float) -> str:
    if seconds < 10.0:
        return f"{seconds:.2f}s"
    else:
        seconds = int(seconds)

    hours = seconds // (60*60)
    seconds %= (60*60)
    minutes = seconds // 60
    seconds %= 60

    r = ""
    if hours > 0:
        r += f"{hours}h"

    if minutes > 0 or hours > 0:
        if hours > 0:
            r += f"{minutes:02d}m"
        else:
            r += f"{minutes}m"

    if hours > 0 or minutes > 0:
        r += f"{seconds:02d}s"
    else:
        r += f"{seconds}s"

    return r

def decimals(x : float, d : int, suffix=None) -> str:
    if suffix.strip() == "" or suffix is None:
        return f"{round(x, d)}"
    return f"{round(x, d)} {suffix}"

palette_5 = ["#121510FF", "#6D8325FF", "#D6CFB7FF", "#E5AD4FFF", "#BD5630FF"]
palette_3 = ["#A8DADC", "#6D6875", "#B5838D"]
palette_3_2 = [color for color in palette_3 for _ in range(2)]
palette_logan = ["#482677", "#2D708E", "#29AF7F" ]
FIG_SIZE = (8,6)