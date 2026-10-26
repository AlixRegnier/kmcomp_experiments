from utils import *
from plotnine import *
import pandas as pd

blocksize = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]

indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]
exps = ["compression", "picompression"]
values = []
color = []
group = []
shape = []
category = []

for exp in exps:
    for index in indexes:
        for size in blocksize:
            d = get_dict_from_json(f"{EXP_DIR}/usage/picompression/usage_{exp}_{index}_{size}kb.json")

            category.append(size)
            color.append(index)
            group.append(index + "_NO_REORDER")
            shape.append("compressed")
            values.append(d["compressed"])

            category.append(size)
            color.append(index)
            group.append(index)
            shape.append("π-compressed")
            values.append(d["picompressed"])

# Sample data
df = pd.DataFrame({
    "category": category,
    "group":    group,
    "color":    color,
    "shape":    shape,
    "value":    values
})

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