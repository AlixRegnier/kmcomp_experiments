from utils import *
from plotnine import *
import pandas as pd

indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]

exps = []
category = []
group = []
value = []

for index in indexes:
    d = get_dict_from_json(f"{EXP_DIR}/metrics/subsample/{index}_size.json")

    for exp in d:
        category.append(int(exp))
        group.append(index)
        value.append(d[exp])

    exps = list(map(int, sorted(d.keys())))


# Sample data
df = pd.DataFrame({
    "category": category,
    "group":    group,
    "value":    value
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