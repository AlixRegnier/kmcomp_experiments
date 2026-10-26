from utils import *
from plotnine import *
import pandas as pd

blocksize = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]
exps = ["compression", "picompression"]
exps_pretty = dict(zip(exps, ["compressed", "π-compressed"]))
indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]

category = []
group = []
value = []
shape = []

i = 0
for exp in exps:
    for index in indexes:
        for size in blocksize:
            d = get_dict_from_json(f"{EXP_DIR}/usage/picompression/usage_{exp}_{index}_{size}kb.json")
            value.append(d["time(s)"])
            shape.append(exps_pretty[exp])
            category.append(size)
            group.append(index)
        i += 1

# Sample data
df = pd.DataFrame({
    "category": category,
    "category_order": [*range(len(category))],
    "group":    group,
    "value":    value
})

df['value_label'] = df['value'].apply(time_label)

plot = (
    ggplot(df, aes(x='category', y='value', color='group', group="group+shape", shape="shape")) +
    geom_line(size=1) +
    geom_point(size=3) +
    scale_shape_manual(values=['^', 'o']) + 
    scale_color_manual(palette_3*2) +
    theme_light() +
    scale_x_log10(breaks=blocksize, labels=lambda x: [KMG_pow2(val*1024) for val in x]) +
    scale_y_continuous(labels=lambda x: [time_label(val) for val in x]) + 
    facet_wrap("group", ncol=1, scales="free_y") +
    labs(x='Block size (logarithmic)', y='Time (s)', fill="Dataset", color="Dataset", shape="Compression")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/compression_time_vs_type_x_exp.pdf")