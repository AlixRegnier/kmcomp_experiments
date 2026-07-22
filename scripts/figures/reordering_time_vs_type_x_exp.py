from utils import *
from plotnine import *
import pandas as pd

exps = ["bitpacking", "no_dm_vptree"]
exps_pretty = dict(zip(exps, ["Bitpacking", "Double\nbit matrix\ntransposition"]))
types = ["ECOLI", "SENTERICA", "HUMANGUT"]
value_name = "3_time_reorder(s)"

ddf = {"exps": [], "exps_pretty": [], "types": [], value_name: [] }


for exp in exps:
    for type in types:
        s = []
        for x in [0,1,2,3,4,5,6,"ref"]:
            d = get_dict_from_json(f"{EXP_DIR}/metrics/reorder/metrics_{type}_{exp}_{x}.json")
            s.append(d[value_name])
    
        
        ddf["exps"].append(exp)
        ddf["exps_pretty"].append(exps_pretty[exp])
        ddf["types"].append(type)
        ddf[value_name].append(sum(s)/len(s))

        

# Sample data
df = pd.DataFrame({
    "category": ddf["exps_pretty"],
    "category_order": [*range(len(ddf["exps"]))],
    "group":    ddf["types"],
    "value":    ddf[value_name]
})

df['value_label'] = df['value'].apply(time_label)

plot = (
    ggplot(df, aes(x='reorder(category, category_order)', y='value', fill='group')) +
    geom_col(position='dodge') +
    # Add markers for capped values
    geom_text(
        mapping=aes(label='value_label'),
        position=position_dodge(width=0.9),
        size=8,
        fontweight="semibold",
        va='bottom'
    ) +
    scale_fill_manual(palette_3) +
    theme_light() +
    #theme(axis_text_x=element_text(rotation=23, hjust=1)) + 
    facet_wrap("group", ncol=3, scales="free_y") +
    labs(x='Column reordering method', y='Time (s)', fill="Dataset", color="Dataset")
)

save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/reorder_time_vs_type_x_exp.pdf")