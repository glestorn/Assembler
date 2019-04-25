#include <dos.h>

typedef struct {
	unsigned char symb;
	unsigned char attr;
} VIDEO;

int attr = 0x5e;

void get_reg();
void init();
void print(int offset, int);

//System interrupts (buffer)
// IRQ0-7
void _interrupt(*Old08) (void);
void _interrupt(*Old09) (void);
void _interrupt(*Old0A) (void);
void _interrupt(*Old0B) (void);
void _interrupt(*Old0C) (void);
void _interrupt(*Old0D) (void);
void _interrupt(*Old0E) (void);
void _interrupt(*Old0F) (void);

// IRQ8-15
void _interrupt(*Old70) (void);
void _interrupt(*Old71) (void);
void _interrupt(*Old72) (void);
void _interrupt(*Old73) (void);
void _interrupt(*Old74) (void);
void _interrupt(*Old75) (void);
void _interrupt(*Old76) (void);
void _interrupt(*Old77) (void);


// New interrupt handlers
// IRQ0-7
void _interrupt New08(void) { get_reg(); Old08(); }
void _interrupt New09(void) { attr++; 
							  get_reg(); Old09(); }
void _interrupt New0A(void) { get_reg(); Old0A(); }
void _interrupt New0B(void) { get_reg(); Old0B(); }
void _interrupt New0C(void) { get_reg(); Old0C(); }
void _interrupt New0D(void) { get_reg(); Old0D(); }
void _interrupt New0E(void) { get_reg(); Old0E(); }
void _interrupt New0F(void) { get_reg(); Old0F(); }

// IRQ8-15
void _interrupt New70(void) { get_reg(); Old70(); }
void _interrupt New71(void) { get_reg(); Old71(); }
void _interrupt New72(void) { get_reg(); Old72(); }
void _interrupt New73(void) { get_reg(); Old73(); }
void _interrupt New74(void) { attr++;
							  get_reg(); Old74(); }
void _interrupt New75(void) { get_reg(); Old75(); }
void _interrupt New76(void) { get_reg(); Old76(); }
void _interrupt New77(void) { get_reg(); Old77(); }

int main()
{
	unsigned far *fp;
	init();
	// Make resident program
	FP_SEG(fp) = _psp;
	FP_OFF(fp) = 0x2c;
	_dos_freemem(*fp);
	_dos_keep(0, (_DS - _CS) + (_SP / 16) + 1);
	return 0;
}

// Get data from registers
void get_reg()
{
	int sub = 20;
	int reg;
	// Leading controller
	reg = inp(0x21); //Masks
	print(0 + sub, reg);

	outp(0x20, 0x0B); //Is served
	reg = inp(0x20);
	print(9 + sub, reg);

	outp(0x20, 0x0A); //Requests
	reg = inp(0x20);
	print(18 + sub, reg);

	reg = inp(0xA1); //Masks
	print(80 + sub, reg);

	outp(0xA0, 0x0B); //Is served
	reg = inp(0xA0);
	print(80 + 9 + sub, reg);

	outp(0xA0, 0x0A); //Requests
	reg = inp(0xA0);
	print(80 + 18 + sub, reg);
}


void init()
{
	// IRQ0-7
	Old08 = getvect(0x08); //Timer
	Old09 = getvect(0x09); //Keyboard
	Old0A = getvect(0x0A); //SLAVE REQUEST
	Old0B = getvect(0x0B); //COM2,4
	Old0C = getvect(0x0C); //COM1,3
	Old0D = getvect(0x0D); //LPT2
	Old0E = getvect(0x0E); //Floppy
	Old0F = getvect(0x0F); //LPT1
	// IRQ8-15
	Old70 = getvect(0x70); //CMOS
	Old71 = getvect(0x71); //Respond of ray
	Old72 = getvect(0x72); //Additional devices
	Old73 = getvect(0x73); //Additional devices
	Old74 = getvect(0x74); //Mouse
	Old75 = getvect(0x75); //FPU
	Old76 = getvect(0x76); //1 IDE-Controller
	Old77 = getvect(0x77); //2 IDE-Controller

	setvect(0x08, New08);
	setvect(0x09, New09);
	setvect(0x0A, New0A);
	setvect(0x0B, New0B);
	setvect(0x0C, New0C);
	setvect(0x0D, New0D);
	setvect(0x0E, New0E);
	setvect(0x0F, New0F);

	setvect(0x88, New70);
	setvect(0x89, New71);
	setvect(0x8A, New72);
	setvect(0x8B, New73);
	setvect(0x8C, New74);
	setvect(0x8D, New75);
	setvect(0x8E, New76);
	setvect(0x8F, New77);

	_disable(); // cli

	// Master
	outp(0x20, 0x11);
	outp(0x21, 0x08);
	outp(0x21, 0x04);
	outp(0x21, 0x01);
	// Slave
	outp(0xA0, 0x11);
	outp(0xA1, 0x88);
	outp(0xA1, 0x02);
	outp(0xA1, 0x01);

	_enable(); // sti
}

// Fill videomemory pointer
void print(int offset, int val)
{
	char temp;
	int i;
	VIDEO far* screen = (VIDEO far *)MK_FP(0xB800, 0);
	screen += 12*80 + offset;
	for (i = 7; i >= 0; i--)
	{
		//Count bits
		temp = val % 2;
		val /= 2;
		//Fill the screen
		screen->symb = temp + '0';
		screen->attr = attr;
		screen++;
	}
}