from utils import *
from plotnine import *
import pandas as pd

exps = [100, 1000, 10000, 20000, 50000, 100000]
indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]
value_name = "2a_computed_distances"

ddf = {"exps": [], "types": [], value_name : [] }


for exp in exps:
    for index in indexes:
        s = []
        for i in range(5):
            d = get_dict_from_json(f"{EXP_DIR}/metrics/subsample/metrics_{index}_{exp}_ref_{i}.json")
            s.append(d[value_name])

        ddf["exps"].append(exp)
        ddf["types"].append(index)
        ddf[value_name].append(sum(s)/len(s))

# Sample data
df = pd.DataFrame({
    "category": ddf["exps"],
    "group":    ddf["types"],
    "value":    ddf[value_name]
})


df['value_label'] = df['value'].apply(KM_label)


plot = (
    ggplot(df, aes(x='category', y='value', color='group')) +
    geom_line(size=2) +
    geom_point(size=3) +
    # Add markers for capped values
    # geom_text(
    #     mapping=aes(label='value_label'),
    #     position=position_dodge2(width=1),
    #     size=8,
    #     fontweight="semibold",
    #     va='bottom',
    #     color="black"
    # ) +
    scale_color_manual(palette_3) +
    scale_y_continuous(labels=lambda x: [scientific_float(val) for val in x]) + 
    scale_x_log10(breaks=exps) +
    theme_light() +
    facet_wrap("group", ncol=1, scales="free_y") +
    labs(x='subsampling size (logarithmic)', y='Number of computed distances', fill="Dataset", color="Dataset")
    
)

save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/nb_computed_distances_vs_type_x_subsample.pdf")
