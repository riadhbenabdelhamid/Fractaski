// MASKs for different memory enable signals
#define MASK_MMIO                 0x8000U   // Address Mask to set enable signal for MMIO memory
#define MASK_BRAM                 0x0000U   // Address Mask to set enable signal for BRAM (private memory) 
#define MASK_VRAM                 0x4000U   // Address Mask to set enanle signal for VRAM (shared per row and word-only addressable)

// Memory‑mapped control register addresses
#define REQ_ADDR                  0x8008U   // MMIO Addr for setting/unsetting shared mem access request signal to Row Arbiter
#define GRANT_ADDR                0x8000U   // MMIO Addr for reading grant signal (ReadOnly) which is set by Row Arbiter
#define LOCKED_ADDR               0x800CU   // MMIO Addr for setting/Unsetting shared mem access lock signal to Row Arbiter
#define VRAM_EMPTIED_ADDR         0x8010U   // MMIO Addr for reading the state of the shared mem (empty/full) that is set by Row Synchronizer

//memory-mapped hardware barrier registers
#define REG_HART_BASE_ADDR        0x8014U  // Base address for hart registers (hart0 starts at 0b00101)
#define REG_BARRIER_STATUS_ADDR   0x8054U  // Address to read the combined barrier status


//amount of frac bits for fixed shift use 
#define FIXED_SHIFT 16
typedef int fixed_t;

// Pointers to memory‑mapped registers
volatile unsigned int* const req_reg             = (unsigned int*)REQ_ADDR;
volatile unsigned int* const locked_reg          = (unsigned int*)LOCKED_ADDR;
volatile unsigned int* const uram_emptied_reg    = (unsigned int*)VRAM_EMPTIED_ADDR;
volatile unsigned int* const grant_reg           = (unsigned int*)GRANT_ADDR;
volatile unsigned int* const hart_base_reg       = (unsigned int*)REG_HART_BASE_ADDR;
volatile unsigned int* const barrier_status_reg  = (unsigned int*)REG_BARRIER_STATUS_ADDR;

__attribute__((section(".data")))
static const fixed_t Re_c[180] = {
    51675, 51644, 51549, 51392, 51172, 50890, 50546, 50140, 49673, 49146, 48559, 47912, 47208, 46445, 45626, 44752, 43823, 42841, 41806, 40721, 39585, 38402, 37172, 35897, 34577, 33216, 31814, 30374, 28896, 27384, 25838, 24260, 22653, 21018, 19358, 17674, 15968, 14244, 12501, 10744, 8973, 7192, 5402, 3605, 1803, 0, -1803, -3605, -5402, -7192, -8973, -10744, -12501, -14244, -15968, -17674, -19358, -21018, -22653, -24260, -25838, -27384, -28896, -30374, -31814, -33216, -34577, -35897, -37172, -38402, -39585, -40721, -41806, -42841, -43823, -44752, -45626, -46445, -47208, -47912, -48559, -49146, -49673, -50140, -50546, -50890, -51172, -51392, -51549, -51644, -51675, -51644, -51549, -51392, -51172, -50890, -50546, -50140, -49673, -49146, -48559, -47912, -47208, -46445, -45626, -44752, -43823, -42841, -41806, -40721, -39585, -38402, -37172, -35897, -34577, -33216, -31814, -30374, -28896, -27384, -25838, -24260, -22653, -21018, -19358, -17674, -15968, -14244, -12501, -10744, -8973, -7192, -5402, -3605, -1803, 0, 1803, 3605, 5402, 7192, 8973, 10744, 12501, 14244, 15968, 17674, 19358, 21018, 22653, 24260, 25838, 27384, 28896, 30374, 31814, 33216, 34577, 35897, 37172, 38402, 39585, 40721, 41806, 42841, 43823, 44752, 45626, 46445, 47208, 47912, 48559, 49146, 49673, 50140, 50546, 50890, 51172, 51392, 51549, 51644
};

__attribute__((section(".data")))
static const fixed_t Im_c[180] = {
    0, 1803, 3605, 5402, 7192, 8973, 10744, 12501, 14244, 15968, 17674, 19358, 21018, 22653, 24260, 25838, 27384, 28896, 30374, 31814, 33216, 34577, 35897, 37172, 38402, 39585, 40721, 41806, 42841, 43823, 44752, 45626, 46445, 47208, 47912, 48559, 49146, 49673, 50140, 50546, 50890, 51172, 51392, 51549, 51644, 51675, 51644, 51549, 51392, 51172, 50890, 50546, 50140, 49673, 49146, 48559, 47912, 47208, 46445, 45626, 44752, 43823, 42841, 41806, 40721, 39585, 38402, 37172, 35897, 34577, 33216, 31814, 30374, 28896, 27384, 25838, 24260, 22653, 21018, 19358, 17674, 15968, 14244, 12501, 10744, 8973, 7192, 5402, 3605, 1803, 0, -1803, -3605, -5402, -7192, -8973, -10744, -12501, -14244, -15968, -17674, -19358, -21018, -22653, -24260, -25838, -27384, -28896, -30374, -31814, -33216, -34577, -35897, -37172, -38402, -39585, -40721, -41806, -42841, -43823, -44752, -45626, -46445, -47208, -47912, -48559, -49146, -49673, -50140, -50546, -50890, -51172, -51392, -51549, -51644, -51675, -51644, -51549, -51392, -51172, -50890, -50546, -50140, -49673, -49146, -48559, -47912, -47208, -46445, -45626, -44752, -43823, -42841, -41806, -40721, -39585, -38402, -37172, -35897, -34577, -33216, -31814, -30374, -28896, -27384, -25838, -24260, -22653, -21018, -19358, -17674, -15968, -14244, -12501, -10744, -8973, -7192, -5402, -3605, -1803
};

// Software-based fixed-point multiplication
int soft_mul(int a, int b, int shamt) {
    int sign = 1;
    if(a < 0) { a = -a; sign = -sign; }
    if(b < 0) { b = -b; sign = -sign; }

    unsigned int ua = (unsigned int)a;
    unsigned int ub = (unsigned int)b;
    unsigned long long result = 0;

    // Multiply ua by ub bit‐by‐bit.
    for (int i = 0; i < 32; i++) {
        if (ub & 1) {
            result += ((unsigned long long)ua << i);
        }
        ub >>= 1;
    }
    // Since the operands are in Qint.frac, we must shift right by frac
    int fixed_result = (int)(result >> shamt);
    return sign < 0 ? -fixed_result : fixed_result;
}


// Atomic barrier function
static void atomic_barrier(int hart_id, unsigned int* sense, unsigned int* completed_iter_flag) {
    // Set either 1 or 0 depending on sense for the specific hart
    *(volatile unsigned int*)(hart_base_reg + hart_id) = (*sense? 1 : 0 );

    // Wait for either 0xF if sense==1, or 0x0 if sense==0
    while (*(volatile unsigned int*)barrier_status_reg != (*sense? 0xFU : 0x0)) ; // spin 

    *req_reg = *sense ;
    // Flip the sense for next time
    *sense ^= 1;
    // Toggle flag value
    *completed_iter_flag ^= 1;  
    while (*grant_reg != *completed_iter_flag) { }; // spin-wait until VRAM emptied signal matches flag 
}

//COMPUTING KERNEL CONSTANTS
//--------------------------
#define MAX_ESCAPE_ITER 256
#define RESOLUTION 512 // 512 x 512
#define RESOLUTION_LOG 9
		     
#define x_step ((3 << FIXED_SHIFT) / RESOLUTION) 
#define y_step ((3 << FIXED_SHIFT) / RESOLUTION)
#define x_base  -(3 << (FIXED_SHIFT-1)) //(x from -1.5 to 1.5 )
#define y_base  -(3 << (FIXED_SHIFT-1)) //(y from -1.5 to 1.5 )
					
//COMPUTING KERNEL TASK
//--------------------------
void compute_datastream(unsigned int start,  volatile unsigned char* datastreamptr, unsigned int iter) { 
  for (unsigned int offset = 0; offset < 16; offset++) { 
    for (unsigned int p = 0; p < 64; p++) { 
        unsigned int idx = (start + p + (offset << 9)); 
        unsigned int i = (idx & (RESOLUTION - 1)); // idx % RESOLUTION
        unsigned int j = (idx >> RESOLUTION_LOG);  // idx / RESOLUTION
        
	//*********************************************
        // Calculate coordinates using fixed-point arithmetic
        fixed_t x0 = x_base + soft_mul(i , x_step, 0);
        fixed_t y0 = y_base + soft_mul(j , y_step, 0);
	
        fixed_t zr = x0, zi = y0;
        unsigned int count = 0;
	fixed_t cx0 = Re_c[iter], cy0 = Im_c[iter] ;

        // Mandelbrot iteration
        while (count < MAX_ESCAPE_ITER) {
            fixed_t zr_sq = soft_mul(zr, zr, FIXED_SHIFT);
            fixed_t zi_sq = soft_mul(zi, zi, FIXED_SHIFT);

            if (zr_sq + zi_sq > (4 << FIXED_SHIFT)) break;

            fixed_t new_zr = zr_sq - zi_sq + cx0;
            fixed_t new_zi = (soft_mul(zr, zi, FIXED_SHIFT) << 1) + cy0;
            //fixed_t new_zr = zr_sq - zi_sq + x0 ;
            //fixed_t new_zi = (soft_mul(zr, zi, FIXED_SHIFT) << 1) + y0 ;

            zr = new_zr;
            zi = new_zi;
            count++;
        }
	//*********************************************
	
	*datastreamptr = (unsigned char) count;
       	datastreamptr++;
    }
  }
}

/* ---- Main Execution ----- */
/* ----------------------------- */

void main(unsigned int complete_id) {
    unsigned int sense = 1;
    unsigned int iter = 0;
    unsigned int completed_iter_flag = 0;

    unsigned int col_id = (complete_id >> 9) & 0xF;
    unsigned int row_id = (complete_id >> 2) & 0xF;
    unsigned int thread_id = complete_id  & 0x3;

    //compute vram allocated space based on thread ID
    unsigned int base_uram_addr = (thread_id << 10) | MASK_VRAM;
    volatile unsigned char* datastream_uram_ptr = (volatile unsigned char*) base_uram_addr;

    //assign chunks to threads by assigning start point for each thread
    //unsigned int start = (row_id * 64 * 512) + (col_id * 64  ) + (thread_id * 16 * 512); 
    unsigned int start = (row_id << 15) + (col_id << 6) + (thread_id << 13); 

    //5.2. Main computation loop (generic compute problem)
    //------------------------------------------------------
    do {

        compute_datastream(start,  datastream_uram_ptr, iter);  
        iter = (iter == 179)? 0 : (iter+1) ; 
        atomic_barrier(thread_id, &sense, &completed_iter_flag);

    } while (1);
    //------------------------------------------------------
}

