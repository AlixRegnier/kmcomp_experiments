from utils import *
from plotnine import *
import pandas as pd

blocksize = [65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864]


types = ["ECOLI", "SENTERICA", "HUMANGUT", "ECOLI_NO_REORDER", "SENTERICA_NO_REORDER", "HUMANGUT_NO_REORDER"]

ECOLI_d = get_dict_from_delimited_file("./metrics/block/ECOLI_size.txt")
ECOLI = [int(ECOLI_d[str(b)]) for b in blocksize]

HUMANGUT_d = get_dict_from_delimited_file("./metrics/block/HUMANGUT_size.txt")
HUMANGUT = [int(HUMANGUT_d[str(b)]) for b in blocksize]

SENTERICA_d = get_dict_from_delimited_file("./metrics/block/SENTERICA_size.txt")
SENTERICA = [int(SENTERICA_d[str(b)]) for b in blocksize]

ECOLI_NO_REORDER_d = get_dict_from_delimited_file("./metrics/block/ECOLI_no_reorder_size.txt")
ECOLI_NO_REORDER = [int(ECOLI_NO_REORDER_d[str(b)]) for b in blocksize]

HUMANGUT_NO_REORDER_d = get_dict_from_delimited_file("./metrics/block/HUMANGUT_no_reorder_size.txt")
HUMANGUT_NO_REORDER = [int(HUMANGUT_NO_REORDER_d[str(b)]) for b in blocksize]

SENTERICA_NO_REORDER_d = get_dict_from_delimited_file("./metrics/block/SENTERICA_no_reorder_size.txt")
SENTERICA_NO_REORDER = [int(SENTERICA_NO_REORDER_d[str(b)]) for b in blocksize]

# Assign each curve to a facet
facet_map = {
    'ECOLI': 'ECOLI (π-compressed)',
    'ECOLI_NO_REORDER': 'ECOLI',
    'HUMANGUT': 'HUMANGUT (π-compressed)',
    'HUMANGUT_NO_REORDER': 'HUMANGUT',
    'SENTERICA': 'SENTERICA (π-compressed)',
    'SENTERICA_NO_REORDER': 'SENTERICA',
}

# Sample data
df = pd.DataFrame({
    "category": blocksize*len(types),
    "group":    ["ECOLI"]*len(blocksize) + ["HUMANGUT"]*len(blocksize) + ["SENTERICA"]*len(blocksize) + ["ECOLI_NO_REORDER"]*len(blocksize) + ["HUMANGUT_NO_REORDER"]*len(blocksize) + ["SENTERICA_NO_REORDER"]*len(blocksize),
    "color":    ["ECOLI"]*len(blocksize) + ["HUMANGUT"]*len(blocksize) + ["SENTERICA"]*len(blocksize) + ["ECOLI"]*len(blocksize) + ["HUMANGUT"]*len(blocksize) + ["SENTERICA"]*len(blocksize),
    "shape":    ["π-compressed"] * len(blocksize)*3 + ["compressed"] * len(blocksize)*3,
    "value":    ECOLI + HUMANGUT + SENTERICA + ECOLI_NO_REORDER + HUMANGUT_NO_REORDER + SENTERICA_NO_REORDER
})

df['facet'] = df['group'].map(facet_map)

plot = (
    ggplot(df, aes(x='category', y='value', color='color', group="group", shape="shape")) +
    geom_line(size=1) +
    geom_point(size=3) +
    scale_shape_manual(values=['^', 'o']) + 
    scale_color_manual(palette_3*2) +
    theme_light() +
    scale_x_log10(breaks=blocksize, labels=lambda x: [KMG_pow2(val) for val in x]) +
    scale_y_continuous(labels=lambda x: [MEGA_label(val) for val in x]) + 
    facet_wrap("~facet", ncol=1, scales="free_y") +
    labs(x='Block size (logarithmic)', y='Compressed size (MB)', fill="Dataset", color="Dataset", shape="Compression")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/compressed_size_vs_type_x_blocksize.pdf")