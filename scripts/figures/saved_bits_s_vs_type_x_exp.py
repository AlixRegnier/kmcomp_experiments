from utils import *
from plotnine import *
import pandas as pd

exps = ["compressed", "π-compressed"]
types = ["ECOLI", "SENTERICA", "HUMANGUT"]

def __r(x):
    return int(read_lines_from_file(x)[0])

ECOLI = [  __r(f"{EXP_DIR}/metrics/compression/ECOLI_no_reorder_size.txt"),  __r(f"{EXP_DIR}/metrics/compression/ECOLI_size.txt")]
SENTERICA = [ __r(f"{EXP_DIR}/metrics/compression/SENTERICA_no_reorder_size.txt"),  __r(f"{EXP_DIR}/metrics/compression/SENTERICA_size.txt") ]
HUMANGUT= [  __r(f"{EXP_DIR}/metrics/compression/HUMANGUT_no_reorder_size.txt"),  __r(f"{EXP_DIR}/metrics/compression/HUMANGUT_size.txt") ]

permutation_time = {}
reorder_time = {}
compression_time = {}
compression_no_reorder_time = {}


for type in types:
    p_time = []
    r_time = []
    c_time = []
    c_n_time = []

    for x in range(10):
        d = get_dict_from_json(f"{EXP_DIR}/metrics/permutation/metrics_{type}_no_dm_vptree_fix_masking_{x}.json")
        p_time.append(d["3_time_permutation(s)"])

        d = get_dict_from_json(f"{EXP_DIR}/metrics/permutation/metrics_{type}_no_dm_vptree_fix_masking_{x}.json")
        c_time.append(d["3_time_compression(s)"])

    for x in [0,1,2,3,4,5,6,"ref"]:
        d = get_dict_from_json(f"{EXP_DIR}/metrics/compression/metrics_{type}_no_reorder_{x}.json")
        c_n_time.append(d["3_time_compression(s)"])

        d = get_dict_from_json(f"{EXP_DIR}/metrics/reorder/metrics_{type}_no_dm_vptree_{x}.json")
        r_time.append(d["3_time_reorder(s)"])

    
    permutation_time[type] = sum(p_time)/len(p_time) #Mean permutation time
    reorder_time[type] = sum(r_time)/len(r_time)*256 #Total mean reorder time
    compression_time[type] = sum(c_time)/len(c_time)*256 #Total mean compression time 
    compression_no_reorder_time[type] = sum(c_n_time)/len(c_n_time)*256 #Total mean compression time (when not reordered)


#Without permutation
ECOLI[0] = (RAW_ECOLI - ECOLI[0]) / (compression_no_reorder_time["ECOLI"])
SENTERICA[0] = (RAW_SENTERICA - SENTERICA[0]) / (compression_no_reorder_time["SENTERICA"])
HUMANGUT[0] = (RAW_HUMANGUT - HUMANGUT[0]) / (compression_no_reorder_time["HUMANGUT"])
#With permutation
ECOLI[1] = (RAW_ECOLI - ECOLI[1]) / (permutation_time["ECOLI"] + reorder_time["ECOLI"] + compression_time["ECOLI"])
SENTERICA[1] = (RAW_SENTERICA - SENTERICA[1]) / (permutation_time["SENTERICA"] + reorder_time["SENTERICA"] + compression_time["SENTERICA"])
HUMANGUT[1] = (RAW_HUMANGUT - HUMANGUT[1]) / (permutation_time["HUMANGUT"] + reorder_time["HUMANGUT"] + compression_time["HUMANGUT"])

# Saved bits
df = pd.DataFrame({
    "category": exps*len(types),
    "category_order": [*range(len(exps))]*len(types),
    "group":    ["ECOLI"]*len(exps) + ["HUMANGUT"]*len(exps) + ["SENTERICA"]*len(exps),
    "value":    ECOLI + HUMANGUT + SENTERICA
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


# Time stacked bar plot
df = pd.DataFrame({
    "category": exps*len(types),
    "category_order": [*range(len(exps))]*len(types),
    "group":    ["ECOLI"]*len(exps) + ["HUMANGUT"]*len(exps) + ["SENTERICA"]*len(exps),
    "value":    ECOLI + HUMANGUT + SENTERICA
})

# Example data
df = pd.DataFrame({
    "facet": 4*["ECOLI"] + 4*["HUMANGUT"] + 4*["SENTERICA"],
    "bar":   3*[ "compressed", "π-compressed", "π-compressed", "π-compressed"],
    "segment": 3*["compression", "compression", "reorder", "π-compute"],
    "value": [
        compression_no_reorder_time["ECOLI"], compression_time["ECOLI"], reorder_time["ECOLI"], permutation_time["ECOLI"],
        compression_no_reorder_time["HUMANGUT"], compression_time["HUMANGUT"], reorder_time["HUMANGUT"], permutation_time["HUMANGUT"],
        compression_no_reorder_time["SENTERICA"], compression_time["SENTERICA"], reorder_time["SENTERICA"], permutation_time["SENTERICA"]
    ]
})

df['value_label'] = df['value'].apply(lambda x: decimals(x, 1, "s"))

# Plot
p = (
    ggplot(df, aes(x="bar", y="value", fill="segment"))
    + geom_col()
    + geom_text(
        aes(label="value_label"),
        position=position_stack(vjust=0.5),
        fontweight="semibold",
        size=8
    )
    + facet_wrap("~facet", ncol=3, scales="free_y")
    + theme_light()
    + theme(axis_text_x=element_text(rotation=12))
    + labs(
        x="Experiment",
        y="Time (s)",
        fill="Step"
    )
)

save_as_pdf_pages([p + theme(figure_size=FIG_SIZE)], "./figures/step_time_vs_type_x_exp.pdf")