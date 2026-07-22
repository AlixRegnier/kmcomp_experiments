from utils import *
from plotnine import *
import pandas as pd

exps = [100, 200, 500, 1000, 10000, 20000, 50000, 100000]
types = ["ECOLI", "SENTERICA", "HUMANGUT"]
value_name = "3_time_permutation(s)"

ddf = {"exps": [], "types": [], value_name: [] }


for exp in exps:
    for type in types:
        s = []
        for x in [0,1,2,3,4,5,6,"ref"]:
            d = get_dict_from_json(f"{EXP_DIR}/metrics/subsample/metrics_{type}_{exp}_{x}.json")
            s.append(d[value_name])

        ddf["exps"].append(exp)
        ddf["types"].append(type)
        ddf[value_name].append(sum(s)/len(s))

        

# Sample data
df = pd.DataFrame({
    "category": ddf["exps"],
    "group":    ddf["types"],
    "value":    ddf[value_name]
})

df['value_label'] = df['value'].apply(time_label)

plot = (
    ggplot(df, aes(x='category', y='value', color='group')) +
    geom_line(size=2) +
    geom_point(size=3) +
    # Add markers for capped values
    geom_text(
        mapping=aes(label='value_label'),
        nudge_y=2,
        size=8,
        fontweight="semibold",
        va='bottom',
        color="black"
    ) +
    scale_color_manual(palette_3) +
    theme_light() +
    scale_x_log10(breaks=exps) +
    labs(x='Subsampling size (logarithmic)', y='Time (s)', fill="Dataset", color="Dataset")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/permutation_time_vs_type_x_subsample.pdf")