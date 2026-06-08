#include "tableshimming.h"
#include <QDebug>

TableShimming::TableShimming()
{
}

QString TableShimming::get_measurement(int step)
{
    static int counter_plane = 0;
    static int counter_multi_plane = 0;
    QString text_measurement;

    if (step == 0) {
        text_measurement = insert_plane(F0BASE);
    }
    else if (step == 1) {
        text_measurement = insert_plane(PLANE_1);
        text_measurement += insert_index(INDEX_0);
    }
    else if (step >= 2 && step <= 133) {
        switch (counter_plane) {
        case 0:
            text_measurement = insert_plane(counter_multi_plane + 2);
            text_measurement += insert_index(INDEX_0);
            break;
        case 1: text_measurement = insert_index(INDEX_30); break;
        case 2: text_measurement = insert_index(INDEX_60); break;
        case 3: text_measurement = insert_index(INDEX_90); break;
        case 4: text_measurement = insert_index(INDEX_120); break;
        case 5: text_measurement = insert_index(INDEX_150); break;
        case 6: text_measurement = insert_index(INDEX_180); break;
        case 7: text_measurement = insert_index(INDEX_210); break;
        case 8: text_measurement = insert_index(INDEX_240); break;
        case 9: text_measurement = insert_index(INDEX_270); break;
        case 10: text_measurement = insert_index(INDEX_300); break;
        case 11: text_measurement = insert_index(INDEX_330); break;
        default: break;
        }
        counter_plane++;
        if (counter_plane >= 12) {
            counter_plane = 0;
            counter_multi_plane++;
        }
        if (counter_multi_plane == 13) {
            counter_multi_plane = 0;
        }
    }
    else if (step == 134) {
        text_measurement = insert_plane(PLANE_13);
        text_measurement += insert_index(INDEX_0);
    }
    else if (step == 135) {
        text_measurement = insert_plane(ISOCENTRO);
    }
    else if (step >= 136) {
        counter_plane = 0;
        counter_multi_plane = 0;
    }

    return text_measurement;
}

QString TableShimming::insert_plane(int plane)
{
    switch (plane) {
    case F0BASE:   return write_shimming("\r\n\r\nF0 Base ISOCENTRO\t");
    case PLANE_1:  return write_shimming("\r\n\r\nPLANO 1");
    case PLANE_2:  return write_shimming("\r\n\r\nPLANO 2");
    case PLANE_3:  return write_shimming("\r\n\r\nPLANO 3");
    case PLANE_4:  return write_shimming("\r\n\r\nPLANO 4");
    case PLANE_5:  return write_shimming("\r\n\r\nPLANO 5");
    case PLANE_6:  return write_shimming("\r\n\r\nPLANO 6");
    case PLANE_7:  return write_shimming("\r\n\r\nPLANO 7");
    case PLANE_8:  return write_shimming("\r\n\r\nPLANO 8");
    case PLANE_9:  return write_shimming("\r\n\r\nPLANO 9");
    case PLANE_10: return write_shimming("\r\n\r\nPLANO 10");
    case PLANE_11: return write_shimming("\r\n\r\nPLANO 11");
    case PLANE_12: return write_shimming("\r\n\r\nPLANE 12");
    case PLANE_13: return write_shimming("\r\n\r\nPLANE 13");
    case ISOCENTRO:return write_shimming("\r\n\r\nISOCENTRO\t");
    default: return QString();
    }
}

QString TableShimming::insert_index(int index)
{
    switch (index) {
    case INDEX_0:   return write_shimming("\t[0°]");
    case INDEX_30:  return write_shimming("\t[30°]");
    case INDEX_60:  return write_shimming("\t[60°]");
    case INDEX_90:  return write_shimming("\t[90°]");
    case INDEX_120: return write_shimming("\t[120°]");
    case INDEX_150: return write_shimming("\t[150°]");
    case INDEX_180: return write_shimming("\t[180°]");
    case INDEX_210: return write_shimming("\t[210°]");
    case INDEX_240: return write_shimming("\t[240°]");
    case INDEX_270: return write_shimming("\t[270°]");
    case INDEX_300: return write_shimming("\t[300°]");
    case INDEX_330: return write_shimming("\t[330°]");
    default: return QString();
    }
}

QString TableShimming::write_shimming(const char *txt)
{
    qDebug() << txt;
    return QString::fromLatin1(txt);
}
