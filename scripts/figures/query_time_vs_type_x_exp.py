from utils import *
from plotnine import *
import pandas as pd

BLOCKSIZE = [64]

value_name = "time(s)"

indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]

ddf = { "blocksize": [], "querysize": [], "shape": [], "type": [], "value": [], "curve": [] }

for index in indexes:
    for bsize in BLOCKSIZE:
        for qsize in [150, 150000]:
            s_uncompressed = []
            s = []
            for x in range(20):
                d_uncompressed = get_dict_from_json(f"{EXP_DIR}/usage/query/{index}_query_f{qsize}_{x}_uncompressed.json")
                s_uncompressed.append(d_uncompressed[value_name])

                d = get_dict_from_json(f"{EXP_DIR}/usage/query/{index}_query2_f{qsize}_{bsize}_{x}.json")
                s.append(d[value_name])


            #π-compressed
            ddf["blocksize"].append(bsize)
            ddf["querysize"].append(qsize)
            ddf["shape"].append("π-compressed")
            ddf["type"].append(index)
            ddf["value"].append(sum(s)/len(s))
            ddf["curve"].append(f"{index}_{qsize}")

            #Not compressed
            ddf["blocksize"].append(bsize)
            ddf["querysize"].append(qsize)
            ddf["shape"].append("not compressed")
            ddf["type"].append(index)
            ddf["value"].append(sum(s_uncompressed)/len(s_uncompressed))
            ddf["curve"].append(f"{index}_{qsize}_uncompressed")


# Sample data
df = pd.DataFrame(ddf)

df['value_label'] = df['value'].apply(time_label)
df['querysize'] = df['querysize'].apply(str)


df["curve"] = pd.Categorical(
    df["curve"],
    categories=sorted(list(set(ddf["curve"])), reverse=True),
    ordered=True
)


plot = (
    ggplot(df, aes(x='querysize', y='value', fill='shape', group='curve'))+
    geom_col(position="dodge") +
    geom_text(
        mapping=aes(label='value_label'),
        position=position_dodge(width=0.9),
        size=8,
        fontweight="semibold",
        va='bottom',
        color="black"
    ) +
    scale_fill_manual(values=['#cccccc', '#676767'], name="Compression") +
    theme_light() + 
    facet_wrap("type", ncol=3, scales="free_y") +
    labs(x='Query size', y='Query time (s)', fill="Dataset", color="Dataset", shape="Compression")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/query_time_vs_type_x_exp.pdf")
