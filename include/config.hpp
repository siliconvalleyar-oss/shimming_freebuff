#ifndef CONFIG_H
#define CONFIG_H

/*
 * Application-wide configuration defaults.
 *
 * This file is intentionally minimal — all configurable parameters
 * currently live in their respective subsystems (PortConfig in rs232.hpp,
 * log directory in fileshimming.cpp, etc.).
 *
 * If cross-cutting configuration (e.g. a JSON/YAML settings file) is
 * needed in the future, aggregate the individual config structs here
 * and add a Config::load(path) factory method.
 */

class Config
{
public:
    Config() = default;
    ~Config() = default;

    /*
     * Stub methods retained for backward compatibility with code that
     * still includes this header.  These will be removed once all
     * callers migrate to FileShimming / TableShimming directly.
     */
    void ConfigDate() {}
    void CloseFile() {}
    void setFileShimming(char*) {}
};

#endif // CONFIG_H
