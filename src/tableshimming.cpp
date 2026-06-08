#include "tableshimming.hpp"
#include <QDebug>

/*
 * Static initialisation of the data-driven plane and index tables.
 *
 * DESIGN DECISION: static const QStringList avoids:
 *   - A separate config file (overkill for 15 entries)
 *   - Runtime allocation per instance (shared across all copies)
 *   - Switch/if-ladder maintenance when adding planes
 *
 * The exact output format (\r\n\r\n prefix, optional \t) is preserved
 * from the original protocol to maintain backward compatibility with
 * any downstream parsers.
 */
const QStringList TableShimming::s_planeStrings = {
    /*  0 */ "\r\n\r\nF0 Base ISOCENTRO\t",
    /*  1 */ "\r\n\r\nPLANO 1",
    /*  2 */ "\r\n\r\nPLANO 2",
    /*  3 */ "\r\n\r\nPLANO 3",
    /*  4 */ "\r\n\r\nPLANO 4",
    /*  5 */ "\r\n\r\nPLANO 5",
    /*  6 */ "\r\n\r\nPLANO 6",
    /*  7 */ "\r\n\r\nPLANO 7",
    /*  8 */ "\r\n\r\nPLANO 8",
    /*  9 */ "\r\n\r\nPLANO 9",
    /* 10 */ "\r\n\r\nPLANO 10",
    /* 11 */ "\r\n\r\nPLANO 11",
    /* 12 */ "\r\n\r\nPLANE 12",          // intentional typo kept for protocol compat
    /* 13 */ "\r\n\r\nPLANE 13",
    /* 14 */ "\r\n\r\nISOCENTRO\t",
};

/*
 * Index labels follow the convention [angle°].
 * Adding a new angle requires only appending here; the stepping
 * logic in get_measurement() adapts automatically via indexCount().
 */
const QStringList TableShimming::s_indexStrings = {
    /*  0 */ "\t[0°]",
    /* 30 */ "\t[30°]",
    /* 60 */ "\t[60°]",
    /* 90 */ "\t[90°]",
    /*120 */ "\t[120°]",
    /*150 */ "\t[150°]",
    /*180 */ "\t[180°]",
    /*210 */ "\t[210°]",
    /*240 */ "\t[240°]",
    /*270 */ "\t[270°]",
    /*300 */ "\t[300°]",
    /*330 */ "\t[330°]",
};

TableShimming::TableShimming()
{
}

int TableShimming::totalSteps() const
{
    /*
     * 1 (F0 base) + 1 (plane 1 + index 0)
     * + (planeCount() - 2) * indexCount()  ← planes 2..N × all indices
     * + 1 (plane N + index 0) + 1 (isocenter)
     *
     * This formula automatically scales when planes or indices are added.
     */
    // For 15 planes, 12 indices: 1 + 1 + 13*12 + 1 + 1 = 160
    return 1 + 1 + (planeCount() - 2) * indexCount() + 1 + 1;
}

int TableShimming::planeCount() const
{
    return s_planeStrings.size();
}

int TableShimming::indexCount() const
{
    return s_indexStrings.size();
}

/*
 * Stateful step sequencer for the measurement protocol.
 *
 * WARNING: counter_plane and counter_multi_plane are static so they
 * persist across calls. This is by design — the measurement workflow
 * is a single sequential walk from step 0 to totalSteps()-1.
 * If multiple TableShimming instances are ever needed, these should
 * become instance members instead.
 */
QString TableShimming::get_measurement(int step)
{
    static int counter_plane = 0;
    static int counter_multi_plane = 0;
    QString text_measurement;

    if (step == 0) {
        text_measurement = insert_plane(PLANE_F0BASE);
    }
    else if (step == 1) {
        text_measurement = insert_plane(PLANE_1);
        text_measurement += insert_index(0);
    }
    /*
     * Bulk measurement loop: walks through all remaining planes
     * (PLANE_2 .. PLANE_N) paired with every index.
     *
     * counter_multi_plane selects the plane, counter_plane selects
     * the index within that plane. Both reset independently.
     *
     * This iterative approach is memory-safe for any number of
     * planes or indices as long as counter_plane < indexCount().
     */
    else if (step >= 2 && step <= 1 + (planeCount() - 2) * indexCount()) {
        if (counter_plane == 0) {
            /*
             * First index of a new plane: emit plane header + first index.
             * offset 2 skips F0BASE and PLANE_1 which are handled above.
             */
            text_measurement = insert_plane(counter_multi_plane + 2);
            text_measurement += insert_index(counter_plane);
        } else {
            text_measurement = insert_index(counter_plane);
        }
        counter_plane++;
        if (counter_plane >= indexCount()) {
            counter_plane = 0;
            counter_multi_plane++;
        }
        /*
         * Guard against counter_multi_plane exceeding planeCount() - 2.
         * This should never happen due to the step count formula, but
         * defensive reset prevents runaway.
         */
        if (counter_multi_plane >= planeCount() - 2) {
            counter_multi_plane = 0;
        }
    }
    else if (step == 1 + (planeCount() - 2) * indexCount() + 1) {
        // step 134 in default config: last plane + index 0°
        text_measurement = insert_plane(PLANE_13);
        text_measurement += insert_index(0);
    }
    else if (step == 1 + (planeCount() - 2) * indexCount() + 2) {
        // step 135 in default config: isocenter
        text_measurement = insert_plane(PLANE_ISOCENTRO);
    }
    else if (step >= 1 + (planeCount() - 2) * indexCount() + 3) {
        // Reset state for the next cycle
        counter_plane = 0;
        counter_multi_plane = 0;
    }

    return text_measurement;
}

/*
 * Bounds-checked plane lookup.
 * Logs a warning and returns empty string on out-of-range access.
 */
QString TableShimming::insert_plane(int plane)
{
    if (plane < 0 || plane >= s_planeStrings.size()) {
        qWarning() << "TableShimming: invalid plane index" << plane;
        return QString();
    }
    qDebug().noquote() << "[plane]" << s_planeStrings[plane];
    return s_planeStrings[plane];
}

/*
 * Bounds-checked index lookup.
 */
QString TableShimming::insert_index(int index)
{
    if (index < 0 || index >= s_indexStrings.size()) {
        qWarning() << "TableShimming: invalid index" << index;
        return QString();
    }
    return s_indexStrings[index];
}

QString TableShimming::write_shimming(const char *txt)
{
    qDebug().noquote() << "[shimming]" << txt;
    return QString::fromLatin1(txt);
}
