from utils import *
from plotnine import *
import pandas as pd

exps = ["raw", "compressed", "picompressed"]
exps_pretty = ["raw", "compressed", "π-compressed"]

indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]

def __r(x):
    return int(read_lines_from_file(x)[0])

category_order = []
category = []
value = []
group = []

for index in indexes:
    d = get_dict_from_json(f"{EXP_DIR}/tmp_dir/picompression/size_{index}_64kb.json")
    group.extend([index]*len(d))
    category_order.extend([*range(len(exps))])
    category.extend(exps_pretty)
    value.extend([d[x] for x in exps])

# Sample data
df = pd.DataFrame({
    "category": category,
    "category_order": category_order,
    "group":    group,
    "value":    value
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