from utils import *
from plotnine import *
import pandas as pd

exps = ["no compression", "compressed", "π-compressed"]


types = ["ECOLI", "SENTERICA", "HUMANGUT"]

def __r(x):
    return int(read_lines_from_file(x)[0])

ECOLI = [RAW_ECOLI, __r(f"{EXP_DIR}/metrics/compression/ECOLI_no_reorder_size.txt"),  __r(f"{EXP_DIR}/metrics/compression/ECOLI_size.txt")]
SENTERICA = [RAW_SENTERICA,  __r(f"{EXP_DIR}/metrics/compression/SENTERICA_no_reorder_size.txt"),  __r(f"{EXP_DIR}/metrics/compression/SENTERICA_size.txt") ]
HUMANGUT= [RAW_HUMANGUT,  __r(f"{EXP_DIR}/metrics/compression/HUMANGUT_no_reorder_size.txt"),  __r(f"{EXP_DIR}/metrics/compression/HUMANGUT_size.txt") ]

        
# Sample data
df = pd.DataFrame({
    "category": exps*len(types),
    "category_order": [*range(len(exps))]*len(types),
    "group":    ["ECOLI"]*len(exps) + ["HUMANGUT"]*len(exps) + ["SENTERICA"]*len(exps),
    "value":    ECOLI + HUMANGUT + SENTERICA
})

df['value'] = df['value'].apply(lambda x: x/1024/1024/1024)
df['value_label'] = df['value'].apply(lambda x: decimals(x, 1, "GB"))

plot = (
    ggplot(df, aes(x='reorder(category, category_order)', y='value', fill='group')) +
    geom_col(position="dodge") +
    geom_text(
        mapping=aes(label='value_label'),
        position=position_dodge(width=0.9),
        size=7,
        fontweight="semibold",
        va='bottom'
    ) +
    scale_fill_manual(palette_3) +
    theme_light() +
    theme(axis_text_x=element_text(rotation=23, hjust=1)) + 
    scale_y_continuous(labels=lambda x: [decimals(val, 1, "GB") for val in x]) + 
    facet_wrap("group", ncol=3, scales="free_y") +
    labs(x='Experiment', y='Index size (GB)', fill="Dataset", color="Dataset")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/index_size_vs_type_x_exp.pdf")