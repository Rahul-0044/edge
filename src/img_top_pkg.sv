package img_top_pkg;
    parameter int WIDTH  = 3124;
    parameter int HEIGHT = 3030;
    parameter int PIXELS = WIDTH*HEIGHT;

    // Pixels per clock = 8
    parameter int PCLK    = 8;
    parameter int PIXBITS = 8;

    typedef logic [PIXBITS-1:0] pixel_t;
    typedef pixel_t pix_bus_t[PCLK];
endpackage
