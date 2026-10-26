from utils import *
from plotnine import *
import pandas as pd

BLOCKSIZE = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]
STR_BLOCKSIZE = ["32kB", "64kB", "128kB", "256kB", "512kB", "1MB", "2MB", "4MB", "8MB"]

value_name = "time(s)"

indexes = ["ECOLI", "SENTERICA", "HUMANGUT"]

ddf = { "blocksize": [], "querysize": [], "shape": [], "color": [], "value": [], "curve": [] }

DICT_BSIZE = dict(zip(BLOCKSIZE, STR_BLOCKSIZE))

for index in indexes:
    for bsize in BLOCKSIZE:
        for qsize in [150, 150000]:
            s_uncompressed = []
            s = []
            for x in range(20):
                d_uncompressed = get_dict_from_json(f"{EXP_DIR}/usage/query/{index}_query2_f{qsize}_{x}_uncompressed.json")
                s_uncompressed.append(d_uncompressed[value_name])

                d = get_dict_from_json(f"{EXP_DIR}/usage/query/{index}_query2_f{qsize}_{bsize}_{x}.json")
                s.append(d[value_name])

            #π-compressed
            ddf["blocksize"].append(bsize)
            ddf["querysize"].append(qsize)
            ddf["shape"].append("π-compressed")
            ddf["color"].append(index)
            ddf["value"].append(sum(s)/len(s))
            ddf["curve"].append(f"{index}_{qsize}")
            
            #Not compressed
            ddf["blocksize"].append(bsize)
            ddf["querysize"].append(qsize)
            ddf["shape"].append("not compressed")
            ddf["color"].append(index)
            ddf["value"].append(sum(s_uncompressed)/len(s_uncompressed))
            ddf["curve"].append(f"{index}_{qsize}_uncompressed")


# Sample data
df = pd.DataFrame(ddf)

df['value_label'] = df['value'].apply(time_label)
df['querysize'] = df['querysize'].apply(str)


plot = (
    ggplot(df, aes(x='blocksize', y='value', color='color', shape="shape", group="curve", linetype="querysize")) +
    geom_line(size=1) +
    geom_point(size=3) +
    geom_text(
        mapping=aes(label='value_label'),
        size=8,
        fontweight="semibold",
        va='bottom',
        color="black"
    ) +
    scale_shape_manual(values=['^', 'o']) +
    scale_color_manual(palette_3) +
    theme_light() +
    scale_x_log10(breaks=BLOCKSIZE, labels=STR_BLOCKSIZE) +
    scale_y_log10(labels=lambda x: [time_label(val) for val in x]) + 
    facet_wrap("color", ncol=1, scales="free_y") +
    labs(x='Block size (logarithmic)', y='Query time (s)', fill="Dataset", color="Dataset", shape="Compression")
)

#plot.show()
save_as_pdf_pages([plot + theme(figure_size=FIG_SIZE)], "./figures/query_time_vs_type_x_blocksize.pdf")