from pathlib import Path

import duckdb
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd

from matplotlib import colormaps
from matplotlib.ticker import FuncFormatter


DB_PATH = "dz_case_study.duckdb"
SCHEMA = "dbo"
OUT_DIR = Path("charts")


# ---------------------------------------------------------
# Farben
# ---------------------------------------------------------

SERIES = [
    "#2a78d6",
    "#eb6834",
    "#1baf7a",
    "#eda100",
    "#e87ba4",
    "#008300",
]

REST = "#898781"
SURFACE = "#fcfcfb"
INK = "#0b0b0b"
INK_SEK = "#52514e"
MUTED = "#898781"
GRID = "#e1e0d9"
BASELINE = "#c3c2b7"

SONSTIGE = "Sonstige"


# ---------------------------------------------------------
# Daten laden
# ---------------------------------------------------------

def lade_marts():
    con = duckdb.connect(
        DB_PATH,
        read_only=True,
    )

    mart_a = con.sql(
        f"""
        select *
        from {SCHEMA}.mart_berater_nettoabsatz
        """
    ).df()

    mart_b = con.sql(
        f"""
        select *
        from {SCHEMA}.mart_kundenbuch_aktuell
        """
    ).df()

    con.close()

    for df in (mart_a, mart_b):
        df["datum"] = pd.to_datetime(
            df["datum"]
        )

        df["berater_key"] = (
            df["vrb_filialnr"]
            .astype("string")
            .str.strip()
            + "_"
            + df["vrb_betreuernr"]
            .astype("string")
            .str.strip()
        )

        df.dropna(
            subset=[
                "vrb_filialnr",
                "vrb_betreuernr",
            ],
            inplace=True,
        )

    return mart_a, mart_b


# ---------------------------------------------------------
# Top N + Sonstige
# ---------------------------------------------------------

def top_und_sonstige(
    df,
    kennzahl,
    top_n,
):
    letzter = df["datum"].max()

    top = list(
        df[
            df["datum"] == letzter
        ]
        .groupby("berater_key")[kennzahl]
        .sum()
        .sort_values(
            ascending=False
        )
        .head(top_n)
        .index
    )

    df = df.copy()

    df["serie"] = df["berater_key"]

    df.loc[
        ~df["berater_key"].isin(top),
        "serie",
    ] = SONSTIGE

    zusammengefasst = (
        df.groupby(
            [
                "serie",
                "datum",
            ],
            as_index=False,
        )[kennzahl]
        .sum()
    )

    return (
        zusammengefasst,
        top + [SONSTIGE],
    )


# ---------------------------------------------------------
# Formatierung Mio. EUR
# ---------------------------------------------------------

def mio(x, _pos=None):
    return (
        f"{x / 1_000_000:,.1f}"
        .replace(",", "X")
        .replace(".", ",")
        .replace("X", ".")
    )


# ---------------------------------------------------------
# Standard-Figur
# ---------------------------------------------------------

def neue_figur(
    titel,
    untertitel=None,
):
    fig, ax = plt.subplots(
        figsize=(10, 5.5),
        facecolor=SURFACE,
    )

    ax.set_facecolor(SURFACE)

    fig.suptitle(
        titel,
        x=0.02,
        ha="left",
        fontsize=14,
        color=INK,
        weight="bold",
    )

    if untertitel:
        ax.set_title(
            untertitel,
            loc="left",
            fontsize=10,
            color=INK_SEK,
            pad=14,
        )

    ax.grid(
        axis="y",
        color=GRID,
        linewidth=0.8,
    )

    ax.set_axisbelow(True)

    for kante in (
        "top",
        "right",
        "left",
    ):
        ax.spines[kante].set_visible(
            False
        )

    ax.spines[
        "bottom"
    ].set_color(BASELINE)

    ax.tick_params(
        colors=MUTED,
        labelsize=9,
        length=0,
    )

    return fig, ax


# ---------------------------------------------------------
# Farben für beliebig viele Berater
# ---------------------------------------------------------

def berater_farben(anzahl):
    """
    Erzeugt genügend unterschiedliche Farben
    für beliebig viele Berater.
    """

    if anzahl <= 0:
        return []

    # Für bis zu 6 Berater:
    # deine definierten Unternehmensfarben verwenden
    if anzahl <= len(SERIES):
        return SERIES[:anzahl]

    # Für 7-20 Berater:
    # Matplotlib tab20 verwenden
    if anzahl <= 20:
        cmap = colormaps["tab20"]

        return [
            cmap(i / max(anzahl - 1, 1))
            for i in range(anzahl)
        ]

    # Für mehr als 20 Berater:
    # viridis mit gleichmäßig verteilten Farben
    cmap = colormaps["turbo"]

    return [
        cmap(i / max(anzahl - 1, 1))
        for i in range(anzahl)
    ]

# ---------------------------------------------------------
# Linien zeichnen
# ---------------------------------------------------------

def linien_zeichnen(
    ax,
    daten,
    reihenfolge,
    kennzahl,
):
    anzahl_berater = sum(
        serie != SONSTIGE
        for serie in reihenfolge
    )

    farben = berater_farben(
        anzahl_berater
    )

    slot = 0

    for serie in reihenfolge:
        teil = (
            daten[
                daten["serie"] == serie
            ]
            .sort_values("datum")
        )

        if teil.empty:
            continue

        if serie == SONSTIGE:
            farbe = REST
        else:
            farbe = farben[slot]
            slot += 1

        ax.plot(
            teil["datum"],
            teil[kennzahl],
            color=farbe,
            linewidth=2,
            label=serie,
            marker="o",
            markersize=4,
            markeredgecolor=SURFACE,
            markeredgewidth=1.5,
        )

    ax.legend(
        frameon=False,
        fontsize=8,
        labelcolor=INK_SEK,
        loc="upper left",
        ncol=4,
        bbox_to_anchor=(
            0,
            -0.08,
        ),
    )


# ---------------------------------------------------------
# Speichern
# ---------------------------------------------------------

def speichern(
    fig,
    name,
):
    OUT_DIR.mkdir(
        exist_ok=True
    )

    pfad = OUT_DIR / name

    fig.savefig(
        pfad,
        dpi=200,
        bbox_inches="tight",
        facecolor=SURFACE,
    )

    plt.close(fig)

    print(
        f"  {pfad}"
    )


# ---------------------------------------------------------
# Chart A
# ---------------------------------------------------------

def diagramm_mart_a(
    mart_a,
    top_n,
):
    daten, reihenfolge = (
        top_und_sonstige(
            mart_a,
            "nettoabsatz_kumuliert",
            top_n,
        )
    )

    # Bei vielen Beratern breiter werden
    if top_n <= 10:
        figsize = (10, 5.5)
    elif top_n <= 20:
        figsize = (13, 6)
    else:
        figsize = (15, 6.5)

    fig, ax = plt.subplots(
        figsize=figsize,
        facecolor=SURFACE,
    )

    ax.set_facecolor(
        SURFACE
    )

    fig.suptitle(
        (
            "Mart A - Kumulierter "
            f"Nettoabsatz - Top {top_n} Berater"
        ),
        x=0.02,
        ha="left",
        fontsize=14,
        color=INK,
        weight="bold",
    )

    linien_zeichnen(
        ax,
        daten,
        reihenfolge,
        "nettoabsatz_kumuliert",
    )
    
    ax.grid(
    axis="both",
    color=GRID,
    linewidth=0.8,
    alpha=0.8,
    )

    ax.set_ylabel(
        "Mio. EUR",
        fontsize=9,
        color=MUTED,
    )

    ax.yaxis.set_major_formatter(
        FuncFormatter(mio)
    )

    ax.axhline(
        0,
        color=BASELINE,
        linewidth=1,
    )

    # -----------------------------------------------------
    # X-Achse
    # -----------------------------------------------------

    ax.xaxis.set_major_locator(
        mdates.AutoDateLocator(
            minticks=4,
            maxticks=6,
        )
    )

    ax.xaxis.set_major_formatter(
        mdates.DateFormatter(
            "%d.%m.%Y"
        )
    )

    # Horizontale Datumswerte
    ax.tick_params(
        axis="x",
        labelsize=8,
        rotation=0,
        pad=8,
    )

    # -----------------------------------------------------
    # Layout
    # -----------------------------------------------------

    fig.subplots_adjust(
        left=0.08,
        right=0.95,
        top=0.88,
        bottom=0.27,
    )

    speichern(
        fig,
        f"01_mart_a_top_{top_n}.png",
    )


# ---------------------------------------------------------
# Chart B
# ---------------------------------------------------------

def diagramm_mart_b(
    mart_a,
    mart_b,
    berater_key,
):
    # -----------------------------------------------------
    # Berater filtern
    # -----------------------------------------------------

    mart_a_berater = mart_a[
        mart_a["berater_key"]
        == berater_key
    ].copy()

    mart_b_berater = mart_b[
        mart_b["berater_key"]
        == berater_key
    ].copy()

    if (
        mart_a_berater.empty
        and mart_b_berater.empty
    ):
        print(
            f"Keine Daten für Berater-Key "
            f"'{berater_key}' gefunden."
        )
        return

    # -----------------------------------------------------
    # AuM
    # -----------------------------------------------------

    aum = (
        mart_b_berater
        .groupby(
            "datum",
            as_index=False,
        )["aum"]
        .sum()
    )

    # -----------------------------------------------------
    # Nettoabsatz
    # -----------------------------------------------------

    nettoabsatz = (
        mart_a_berater
        .groupby(
            "datum",
            as_index=False,
        )[
            "nettoabsatz_kumuliert"
        ]
        .sum()
    )

    # -----------------------------------------------------
    # Zusammenführen
    # -----------------------------------------------------

    daten = pd.merge(
        aum,
        nettoabsatz,
        on="datum",
        how="outer",
    ).sort_values(
        "datum"
    )

    daten = daten.dropna(
        subset=[
            "aum",
            "nettoabsatz_kumuliert",
        ],
        how="all",
    )

    # -----------------------------------------------------
    # Figure
    # -----------------------------------------------------

    fig, ax1 = plt.subplots(
        figsize=(10, 5.5),
        facecolor=SURFACE,
    )

    ax1.set_facecolor(
        SURFACE
    )

    fig.suptitle(
        "Mart B - AuM und Nettoabsatz",
        x=0.02,
        y=0.96,
        ha="left",
        fontsize=14,
        color=INK,
        weight="bold",
    )

    ax1.set_title(
        f"Berater: {berater_key}",
        loc="left",
        fontsize=10,
        color=INK_SEK,
        pad=14,
    )

    # -----------------------------------------------------
    # AuM
    # -----------------------------------------------------

    ax1.set_ylabel(
        "AuM Mio. EUR",
        fontsize=9,
        color=SERIES[0],
    )

    ax1.plot(
        daten["datum"],
        daten["aum"],
        color=SERIES[0],
        linewidth=2.5,
        marker="o",
        markersize=4,
        markeredgecolor=SURFACE,
        markeredgewidth=1.5,
        label="AuM",
    )

    ax1.yaxis.set_major_formatter(
        FuncFormatter(mio)
    )

    # -----------------------------------------------------
    # Nettoabsatz
    # -----------------------------------------------------

    ax2 = ax1.twinx()

    ax2.set_ylabel(
        "Nettoabsatz Mio. EUR",
        fontsize=9,
        color=SERIES[1],
    )

    ax2.plot(
        daten["datum"],
        daten[
            "nettoabsatz_kumuliert"
        ],
        color=SERIES[1],
        linewidth=2.5,
        linestyle=(0, (5, 5)),
        marker="o",
        markersize=4,
        markeredgecolor=SURFACE,
        markeredgewidth=1.5,
        label="Nettoabsatz",
    )

    ax2.yaxis.set_major_formatter(
        FuncFormatter(mio)
    )

    # -----------------------------------------------------
    # Grid
    # -----------------------------------------------------

    ax1.grid(
        axis="y",
        color=GRID,
        linewidth=0.8,
    )

    ax1.set_axisbelow(
        True
    )

    # -----------------------------------------------------
    # Achsen
    # -----------------------------------------------------

    for ax in (
        ax1,
        ax2,
    ):
        ax.spines[
            "top"
        ].set_visible(False)

        ax.tick_params(
            colors=MUTED,
            labelsize=9,
            length=0,
        )

    ax1.spines[
        "left"
    ].set_visible(False)

    ax1.spines[
        "bottom"
    ].set_color(BASELINE)

    ax2.spines[
        "right"
    ].set_visible(False)

    # -----------------------------------------------------
    # X-Achse
    # -----------------------------------------------------

    ax1.xaxis.set_major_locator(
        mdates.AutoDateLocator(
            minticks=4,
            maxticks=6,
        )
    )

    ax1.xaxis.set_major_formatter(
        mdates.DateFormatter(
            "%d.%m.%Y"
        )
    )

    ax1.tick_params(
        axis="x",
        labelsize=8,
        rotation=0,
        pad=8,
    )

    # -----------------------------------------------------
    # Legende
    # -----------------------------------------------------

    lines1, labels1 = (
        ax1.get_legend_handles_labels()
    )

    lines2, labels2 = (
        ax2.get_legend_handles_labels()
    )

    ax1.legend(
        lines1 + lines2,
        labels1 + labels2,
        frameon=False,
        fontsize=9,
        labelcolor=INK_SEK,
        loc="upper left",
        ncol=2,
        bbox_to_anchor=(
            0,
            -0.18,
        ),
    )

    # -----------------------------------------------------
    # Layout
    # -----------------------------------------------------

    fig.subplots_adjust(
        bottom=0.27,
        top=0.80,
        left=0.08,
        right=0.92,
    )

    # -----------------------------------------------------
    # Speichern
    # -----------------------------------------------------

    dateiname = (
        "02_mart_b_"
        f"{berater_key.replace('/', '_')}.png"
    )

    speichern(
        fig,
        dateiname,
    )


# ---------------------------------------------------------
# Top N auswählen
# ---------------------------------------------------------

def top_n_auswaehlen():
    print()
    print(
        "Wie viele Top-Berater sollen "
        "in Chart A angezeigt werden?"
    )

    print(
        "Beispiele: 5, 10, 20"
    )

    print()

    while True:
        eingabe = input(
            "Top N eingeben: "
        ).strip()

        try:
            top_n = int(
                eingabe
            )

            if top_n <= 0:
                print(
                    "Bitte eine Zahl "
                    "größer als 0 eingeben."
                )
                continue

            return top_n

        except ValueError:
            print(
                "Ungültige Eingabe. "
                "Bitte eine ganze Zahl "
                "eingeben, z.B. 5, 10 oder 20."
            )


# ---------------------------------------------------------
# Berater auswählen
# ---------------------------------------------------------

def berater_auswaehlen(
    mart_a,
    mart_b,
):
    berater_a = set(
        mart_a[
            "berater_key"
        ]
        .dropna()
        .unique()
    )

    berater_b = set(
        mart_b[
            "berater_key"
        ]
        .dropna()
        .unique()
    )

    berater = sorted(
        berater_a.union(
            berater_b
        )
    )

    if not berater:
        print(
            "Keine Berater gefunden."
        )
        return None

    print()
    print(
        "Verfügbare Berater:"
    )
    print(
        "-" * 30
    )

    for key in berater:
        print(
            f"  {key}"
        )

    print(
        "-" * 30
    )

    while True:
        berater_key = input(
            "\nBitte Berater-Key eingeben: "
        ).strip()

        if berater_key in berater:
            return berater_key

        print(
            f"Berater-Key "
            f"'{berater_key}' "
            "wurde nicht gefunden."
        )

        print(
            "Bitte einen der oben "
            "angezeigten Keys eingeben."
        )


# ---------------------------------------------------------
# Main
# ---------------------------------------------------------

def main():
    print(
        "Lade Marts ..."
    )

    mart_a, mart_b = (
        lade_marts()
    )

    print(
        "Marts geladen."
    )

    # -----------------------------------------------------
    # Top N für Chart A
    # -----------------------------------------------------

    top_n = (
        top_n_auswaehlen()
    )

    print(
        f"\nErzeuge Chart A "
        f"für Top {top_n} Berater ..."
    )

    diagramm_mart_a(
        mart_a,
        top_n,
    )

    # -----------------------------------------------------
    # Berater für Chart B
    # -----------------------------------------------------

    berater_key = (
        berater_auswaehlen(
            mart_a,
            mart_b,
        )
    )

    if berater_key is None:
        print(
            "Kein Berater ausgewählt."
        )
        return

    print(
        f"\nErzeuge Chart B "
        f"für Berater: "
        f"{berater_key}"
    )

    diagramm_mart_b(
        mart_a,
        mart_b,
        berater_key,
    )

    print(
        "\nFertig."
    )


if __name__ == "__main__":
    main()

