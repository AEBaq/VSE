// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

// YTA : Adapted from https://github.com/dpretet/svlogger
//       Added a `define LOGCOLOR that can be activated for writing with colors

`ifndef SVLOGGER
`define SVLOGGER

`define SVL_VERBOSE_OFF 0
`define SVL_VERBOSE_DEBUG 1
`define SVL_VERBOSE_INFO 2
`define SVL_VERBOSE_WARNING 3
`define SVL_VERBOSE_CRITICAL 4
`define SVL_VERBOSE_ERROR 5

`define SVL_ROUTE_TERM 1
`define SVL_ROUTE_FILE 2
`define SVL_ROUTE_ALL 3

// YTA: Macros to help with string formatting. You are encouraged to use them
`define LOG_DEBUG(logger, a) logger.debug(a)
`define LOG_DEBUG2(logger, a, b) begin string s; $sformat(s, a, b);logger.debug(s); end
`define LOG_DEBUG3(logger, a, b, c) begin string s; $sformat(s, a, b, c);logger.debug(s); end
`define LOG_DEBUG4(logger, a, b, c, d) begin string s; $sformat(s, a, b, c, d);logger.debug(s); end

`define LOG_INFO(logger, a) logger.info(a)
`define LOG_INFO2(logger, a, b) begin string s; $sformat(s, a, b);logger.info(s); end
`define LOG_INFO3(logger, a, b, c) begin string s; $sformat(s, a, b, c);logger.info(s); end
`define LOG_INFO4(logger, a, b, c, d) begin string s; $sformat(s, a, b, c, d);logger.info(s); end

`define LOG_WARNING(logger, a) logger.warning(a)
`define LOG_WARNING2(logger, a, b) begin string s; $sformat(s, a, b);logger.warning(s); end
`define LOG_WARNING3(logger, a, b, c) begin string s; $sformat(s, a, b, c);logger.warning(s); end
`define LOG_WARNING4(logger, a, b, c, d) begin string s; $sformat(s, a, b, c, d);logger.warning(s); end

`define LOG_ERROR(logger, a) logger.error(a)
`define LOG_ERROR2(logger, a, b) begin string s; $sformat(s, a, b);logger.error(s); end
`define LOG_ERROR3(logger, a, b, c) begin string s; $sformat(s, a, b, c);logger.error(s); end
`define LOG_ERROR4(logger, a, b, c, d) begin string s; $sformat(s, a, b, c, d);logger.error(s); end

`define LOG_CRITICAL(logger, a) logger.critical(a)
`define LOG_CRITICAL2(logger, a, b) begin string s; $sformat(s, a, b);logger.critical(s); end
`define LOG_CRITICAL3(logger, a, b, c) begin string s; $sformat(s, a, b, c);logger.critical(s); end
`define LOG_CRITICAL4(logger, a, b, c, d) begin string s; $sformat(s, a, b, c, d);logger.critical(s); end


class svlogger;

    ////////////////////////////////////////////
    // Name of the module printed in the console
    // and/or the log file name
    string name;

    ///////////////////////////////////
    // Verbosity level of the instance:
    //   - 0: no logging
    //   - 1: debug/info/warning/critical/error
    //   - 2: info/warning/critical/error
    //   - 3: warning/critical/error
    //   - 4: critical/error
    //   - 5: error
    int verbosity;

    ///////////////////////////////////////////////////////
    // Define if log in the console, in a log file or both:
    //   - 1: console only
    //   - 2: log file only
    //   - 3: console and log file
    int route;

    // pointer to log file
    integer f;

    // color codes:
    // BLACK      "\033[1;30m"
    // RED        "\033[1;31m"
    // GREEN      "\033[1;32m"
    // BROWN      "\033[1;33m"
    // BLUE       "\033[1;34m"
    // PINK       "\033[1;35m"
    // CYAN       "\033[1;36m"
    // WHITE      "\033[1;37m"
    // NC         "\033[0m"

    // constructor
    function new(
        string  _name,
        int     _verbosity,
        int     _route
    );
        this.name = _name;
        this.verbosity = _verbosity;
        this.route = _route;
        if (this.route==`SVL_ROUTE_FILE || this.route==`SVL_ROUTE_ALL) begin
            this.f = $fopen({this.name, ".txt"},"w");
        end
    endfunction

    // Internal function to log into console and/or log file
    // Internal use only
    function void _log_text(string text, int severity);
    begin
        string t_text;
        if (this.route==`SVL_ROUTE_TERM || this.route==`SVL_ROUTE_ALL) begin
            case (severity)
                `SVL_VERBOSE_ERROR: $error(text);
                `SVL_VERBOSE_CRITICAL: $fatal(text);
                `SVL_VERBOSE_INFO: $info(text);
                `SVL_VERBOSE_WARNING: $warning(text);
                default: $display(text);
            endcase
        end
        if (this.route==`SVL_ROUTE_FILE || this.route==`SVL_ROUTE_ALL) begin
            $sformat(t_text, "%s\n", text);
            $fwrite(this.f, t_text);
        end
    end
    endfunction

    // Just write a message without any formatting neither time printed
    // Could be used for further explanation of a previous debug/info ...
    function void msg(string text);
    begin
        _log_text(text, `SVL_VERBOSE_INFO);
    end
    endfunction

    // Print a debug message, in white
    function void debug(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_INFO && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            `ifdef LOGCOLOR
            $sformat(t_text, "\033[0;37m%s: DEBUG: (@ %0t) %s \033[0m", this.name, $realtime, text);
            `else
            $sformat(t_text, "%s: DEBUG: (@ %0t) %s", this.name, $realtime, text);
            `endif
            _log_text(t_text, `SVL_VERBOSE_INFO);
        end
    end
    endfunction

    // Print an info message, in blue
    function void info(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_WARNING && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            `ifdef LOGCOLOR
            $sformat(t_text, "\033[0;34m%s: INFO: (@ %0t) %s \033[0m", this.name, $realtime, text);
            `else
            $sformat(t_text, "%s: INFO: (@ %0t) %s", this.name, $realtime, text);
            `endif
            _log_text(t_text, `SVL_VERBOSE_INFO);
        end
    end
    endfunction

    // Print a warning message, in yellow
    function void warning(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_CRITICAL && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            `ifdef LOGCOLOR
            $sformat(t_text, "\033[1;33m%s: WARNING: (@ %0t) %s \033[0m", this.name, $realtime, text);
            `else
            $sformat(t_text, "%s: WARNING: (@ %0t) %s", this.name, $realtime, text);
            `endif
            _log_text(t_text, `SVL_VERBOSE_WARNING);
        end
    end
    endfunction

    // Print a critical message, in pink
    function void critical(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_ERROR && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            `ifdef LOGCOLOR
            $sformat(t_text, "\033[1;35m%s: CRITICAL: (@ %0t) %s \033[0m", this.name, $realtime, text);
            `else
                $sformat(t_text, "%s: CRITICAL: (@ %0t) %s", this.name, $realtime, text);
            `endif
            _log_text(t_text, `SVL_VERBOSE_CRITICAL);
        end
    end
    endfunction

    // Print an error message, in red
    function void error(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_ERROR+1 && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            `ifdef LOGCOLOR
            $sformat(t_text, "\033[1;31m%s: ERROR: (@ %0t) %s \033[0m", this.name, $realtime, text);
            `else
                $sformat(t_text, "%s: ERROR: (@ %0t) %s", this.name, $realtime, text);
            `endif
            _log_text(t_text, `SVL_VERBOSE_ERROR);
        end
    end
    endfunction

    static svlogger m_instance;

    static function svlogger getInstance(
        string  _name = "",
        int     _verbosity = `SVL_VERBOSE_INFO,
        int     _route = `SVL_ROUTE_TERM);
        if (m_instance == null)
            m_instance = new(_name, _verbosity, _route);
        return m_instance;
    endfunction

endclass


`endif
