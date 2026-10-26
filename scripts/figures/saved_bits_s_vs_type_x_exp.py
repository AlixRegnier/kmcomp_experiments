from utils import *
from plotnine import *
import pandas as pd

exps = ["compressed", "π-compressed"]
indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]

values = { index : get_dict_from_json(f"{EXP_DIR}/tmp_dir/picompression/size_{index}_64kb.json") for index in indexes }

compression_time = {}
picompression_time = {}


for index in indexes:
    d = get_dict_from_json(f"{EXP_DIR}/usage/picompression/usage_compression_{index}_64kb.json")
    compression_time[index] = d["time(s)"]

    d = get_dict_from_json(f"{EXP_DIR}/usage/picompression/usage_picompression_{index}_64kb.json")
    picompression_time[index] = d["time(s)"]


#Without permutation
for index in indexes:
    values[index]["saved_bits_s_compressed"] = (values[index]["raw"] - values[index]["compressed"]) / (compression_time[index])

    #With permutation
    values[index]["saved_bits_s_picompressed"] = (values[index]["raw"] - values[index]["picompressed"]) / (picompression_time[index])

group = [ index for index in indexes for _ in range(len(exps))]
value = [ values[index][k] for index in indexes for k in ["saved_bits_s_compressed", "saved_bits_s_picompressed"]]

# Saved bits
df = pd.DataFrame({
    "category": exps*len(indexes),
    "category_order": [*range(len(exps))]*len(indexes),
    "group":    group,
    "value":    value
})

df['value'] = df['value'].apply(lambda x: x/1024/1024) #Mega
df['value_label'] = df['value'].apply(lambda x: decimals(x, 1, "MB/s"))

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
    theme(axis_text_x=element_text(rotation=12)) + 
    scale_y_continuous() +#labels=lambda x: [decimals(val, 1, "MB/s") for val in x]) + 
    facet_wrap("group", ncol=3, scales="free_y") +
    labs(x='Experiment', y='Saved MB/s', fill="Dataset", color="Dataset")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/saved_bits_s_vs_type_x_exp.pdf")


# # Time stacked bar plot
# df = pd.DataFrame({
#     "category": exps*len(types),
#     "category_order": [*range(len(exps))]*len(types),
#     "group":    ["ECOLI"]*len(exps) + ["HUMANGUT"]*len(exps) + ["SENTERICA"]*len(exps),
#     "value":    ECOLI + HUMANGUT + SENTERICA
# })

# # Example data
# df = pd.DataFrame({
#     "facet": 4*["ECOLI"] + 4*["HUMANGUT"] + 4*["SENTERICA"],
#     "bar":   3*[ "compressed", "π-compressed", "π-compressed", "π-compressed"],
#     "segment": 3*["compression", "compression", "reorder", "π-compute"],
#     "value": [
#         compression_no_reorder_time["ECOLI"], compression_time["ECOLI"], reorder_time["ECOLI"], permutation_time["ECOLI"],
#         compression_no_reorder_time["HUMANGUT"], compression_time["HUMANGUT"], reorder_time["HUMANGUT"], permutation_time["HUMANGUT"],
#         compression_no_reorder_time["SENTERICA"], compression_time["SENTERICA"], reorder_time["SENTERICA"], permutation_time["SENTERICA"]
#     ]
# })

# df['value_label'] = df['value'].apply(lambda x: decimals(x, 1, "s"))

# # Plot
# p = (
#     ggplot(df, aes(x="bar", y="value", fill="segment"))
#     + geom_col()
#     + geom_text(
#         aes(label="value_label"),
#         position=position_stack(vjust=0.5),
#         fontweight="semibold",
#         size=8
#     )
#     + facet_wrap("~facet", ncol=3, scales="free_y")
#     + theme_light()
#     + theme(axis_text_x=element_text(rotation=12))
#     + labs(
#         x="Experiment",
#         y="Time (s)",
#         fill="Step"
#     )
# )

# save_as_pdf_pages([p + theme(figure_size=FIG_SIZE)], "./figures/step_time_vs_type_x_exp.pdf")
