//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.010-spacer.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
    public:
    //! \class      Spacer
    //! \brief      For debug indentations
    class Spacer
    {
        private:
        std::string     a_spaces;

        public:
        const   char    *   cstr()  { return a_spaces.c_str();  }

        void                inc()   { a_spaces.append("  ");    }
        void                dec()
            {
                if ( ! a_spaces.length() )
                {
                    LXG_INTERRUPT_MSG("%s\n", "Spacer::dec():spaces std::string is empty");
                }
                a_spaces.erase( 0, 2);
            }

        public:
        Spacer()
        {
        }
        ~Spacer()
        {
        }
    };
    //  ########################################################################
    //! \class  Chrono
    //! \brief  For measuring time
    class Chrono
    {

    //  int clock_gettime(clockid_t clk_id, struct timespect *tp);

    private:
        timespec    a_t_start;
        timespec    a_t_timed;
        timespec    a_t_diff;

        bool        a_started;
        bool        a_timed;

    private:
    //  Guy rutenberg
    void    p_diff()
    {
        if ( ( a_t_timed.tv_nsec - a_t_start.tv_nsec ) < 0 )
        {
            a_t_diff.tv_sec     = a_t_timed.tv_sec  -   a_t_start.tv_sec    -   1;
            a_t_diff.tv_nsec    = 1000000000        +   a_t_timed.tv_nsec   -   a_t_start.tv_nsec;
        }
        else
        {
            a_t_diff.tv_sec     = a_t_timed.tv_sec  -   a_t_start.tv_sec;
            a_t_diff.tv_nsec    = a_t_timed.tv_nsec -   a_t_start.tv_nsec;
        }
    }


    bool    p_get_time( timespec* _tspc)
        {
            if ( clock_gettime( CLOCK_MONOTONIC_RAW, _tspc ) != 0 )
            {
                LXG_ERR( "%s [%s]\n", "Chrono::p_get_time():clock_gettime failed", strerror(errno));
                return false;
            }
            return true;
        }
    public:
    void    start()
        {
            a_started   =   false;
            a_timed     =   false;

            if ( p_get_time(&a_t_start) )
            {
                a_started   =   true;
            }
        }
    void    time()
        {
            if ( ! a_started )
                return;

            if ( ! p_get_time(&a_t_timed) )
            {
                return;
            }
            a_timed =   true;

            p_diff();
        }

    time_t  es()
    {
        if ( a_timed )
            return a_t_diff.tv_sec;

        return 0;
    }
    long    ens()
    {
        if ( a_timed )
            return a_t_diff.tv_nsec;

        return 0;
    }

    public:
        Chrono()
        {
        }
        virtual ~Chrono()   {}
    };
    //  ########################################################################



