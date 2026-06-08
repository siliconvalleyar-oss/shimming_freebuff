#ifndef TABLESHIMMING_H
#define TABLESHIMMING_H

#include <QString>
#include <QStringList>

/*
 * Generates measurement protocol strings for MRI shimming sequences.
 *
 * Scalability: plane names and index labels are data-driven via static
 * arrays instead of switch/if-ladders. Adding a new plane or index only
 * requires appending to the list — no logic changes.
 *
 * The stepping algorithm is a state machine that walks plane × index
 * pairs sequentially, which maps cleanly to the NMR measurement workflow:
 *   step 0       → F0 base
 *   step 1       → plane 1 + index 0°
 *   steps 2–133  → plane[2..N] × index[0°..330°]
 *   step 134     → plane N + index 0°
 *   step 135     → isocenter
 *   step ≥136    → reset
 */

class TableShimming
{
public:
    TableShimming();
    ~TableShimming() = default;

    /*
     * Returns the formatted measurement string for the given step index.
     * The internal counter advances through planes and indices.
     * Returns empty string on reset (step >= totalSteps()).
     */
    QString get_measurement(int step);

    /*
     * Returns the total number of steps in a complete cycle.
     */
    int totalSteps() const;

    /*
     * Returns the number of defined planes (for external config).
     */
    int planeCount() const;

    /*
     * Returns the number of defined indices (for external config).
     */
    int indexCount() const;

private:
    /*
     * Lookup: plane index → formatted output string.
     * The returned string includes the \r\n\r\n prefix and trailing tab
     * where required by the original legacy format.
     */
    QString insert_plane(int plane);

    /*
     * Lookup: index index → formatted output string with \t prefix.
     */
    QString insert_index(int index);

    /*
     * Wraps text for debug output and returns it as a QString.
     */
    QString write_shimming(const char *txt);

    /*
     * Data-driven plane definitions.
     * Keep sorted by enum value; index 0 → first string.
     * To add a new plane, append to this list.
     */
    static const QStringList s_planeStrings;

    /*
     * Data-driven index definitions.
     * Keep sorted by angle ascending; index 0 → 0°.
     * To add a new index, append to this list.
     */
    static const QStringList s_indexStrings;

    /*
     * Plane enum values exposed as compile-time constants so the
     * stepping logic in get_measurement() remains readable without
     * a full enum type (which cannot be extended at runtime).
     * These correspond to indices into s_planeStrings.
     */
    static constexpr int PLANE_F0BASE   = 0;
    static constexpr int PLANE_1       = 1;
    static constexpr int PLANE_13      = 13;
    static constexpr int PLANE_ISOCENTRO = 14;
};

#endif // TABLESHIMMING_H
