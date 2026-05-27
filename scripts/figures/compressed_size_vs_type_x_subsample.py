from utils import *
from plotnine import *
import pandas as pd

exps = [100, 200, 500, 1000, 10000, 20000, 50000, 100000]
types = ["ECOLI", "SENTERICA", "HUMANGUT"]

ECOLI_d = get_dict_from_delimited_file("./metrics/subsample/ECOLI_size.txt")
ECOLI = [int(ECOLI_d[str(exp)]) for exp in exps]


HUMANGUT_d = get_dict_from_delimited_file("./metrics/subsample/HUMANGUT_size.txt")
HUMANGUT = [int(HUMANGUT_d[str(exp)]) for exp in exps]

SENTERICA_d = get_dict_from_delimited_file("./metrics/subsample/SENTERICA_size.txt")
SENTERICA = [int(SENTERICA_d[str(exp)]) for exp in exps]


# Sample data
df = pd.DataFrame({
    "category": exps*len(types),
    "group":    ["ECOLI"]*len(exps) + ["HUMANGUT"]*len(exps) + ["SENTERICA"]*len(exps),
    "value":    ECOLI + HUMANGUT + SENTERICA
})

df['value_label'] = df['value'].apply(MEGA_label)

plot = (
    ggplot(df, aes(x='category', y='value', color='group')) +
    geom_line(size=2) +
    geom_point(size=3) +
    scale_color_manual(palette_3) +
    theme_light() +
    scale_x_log10(breaks=exps) +
    scale_y_continuous(labels=lambda x: [MEGA_label(val) for val in x]) + 
    facet_wrap("group", ncol=1, scales="free_y") +
    labs(x='Subsampling size (logarithmic)', y='Compressed size (MB)', fill="Dataset", color="Dataset")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/compressed_size_vs_type_x_subsample.pdf")