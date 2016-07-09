/*
 * Exynos Specific Extensions for Synopsys DW Multimedia Card Interface driver
 *
 * Copyright (C) 2012, Samsung Electronics Co., Ltd.
 * Copyright (C) 2013, The Chromium OS Authors
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#define NUM_PINS(x)			(x + 2)

#define DWMCI_RESP_RCLK_MODE			BIT(5)
#define EXYNOS_DEF_MMC_0_CAPS	(MMC_CAP_UHS_DDR50 | MMC_CAP_1_8V_DDR | \
				MMC_CAP_8_BIT_DATA | MMC_CAP_CMD23 | \
				MMC_CAP_ERASE)
#define EXYNOS_DEF_MMC_1_CAPS	MMC_CAP_CMD23
#define EXYNOS_DEF_MMC_2_CAPS	(MMC_CAP_CMD23 | MMC_CAP_UHS_SDR50 | \
				MMC_CAP_UHS_SDR104 | MMC_CAP_ERASE)

#define MAX_TUNING_RETRIES	6
#define MAX_TUNING_LOOP		(MAX_TUNING_RETRIES * 8 * 2)

/* Variations in Exynos specific dw-mshc controller */
enum dw_mci_exynos_type {
	DW_MCI_TYPE_EXYNOS4210,
	DW_MCI_TYPE_EXYNOS4412,
	DW_MCI_TYPE_EXYNOS5250,
	DW_MCI_TYPE_EXYNOS5422,
	DW_MCI_TYPE_EXYNOS5430,
};

/* Exynos implementation specific driver private data */
struct dw_mci_exynos_priv_data {
	u8			ciu_div;
	u32			sdr_timing;
	u32			sdr_hs_timing;
	u32			ddr_timing;
	u32			hs200_timing;
	u32			ddr200_timing;
	u32			ddr200_ulp_timing;
	u32			ddr200_tx_t_fastlimit;
	u32			ddr200_tx_t_initval;
	u32			*ref_clk;
	const char		*drv_str_pin;
	const char		*drv_str_addr;
	int			drv_str_val;
	u32			delay_line;
	u32			tx_delay_line;
	int			drv_str_base_val;
	u32			drv_str_num;
	int			cd_gpio;
	int			sec_sd_slot_type;
#define SEC_DEFAULT_SD_SLOT	0 /* No detect GPIO SD slot case */
#define SEC_HOTPLUG_SD_SLOT	1 /* detect GPIO SD slot without Tray */
#define SEC_HYBRID_SD_SLOT	2 /* detect GPIO SD slot with Tray */
	int			vqmmc_en_gpio;
	int			vmmc_en_gpio;
	u32			caps;
	u32			ctrl_flag;
	u32			ignore_phase;
	u32			selclk_drv;

#define DW_MMC_EXYNOS_USE_FINE_TUNING		BIT(0)
#define DW_MMC_EXYNOS_BYPASS_FOR_ALL_PASS	BIT(1)
#define DW_MMC_EXYNOS_ENABLE_SHIFT		BIT(2)
};

/*
 * Tunning patterns are from emmc4.5 spec section 6.6.7.1
 * Figure 27 (for 8-bit) and Figure 28 (for 4bit).
 */
static const u8 tuning_blk_pattern_4bit[] = {
	0xff, 0x0f, 0xff, 0x00, 0xff, 0xcc, 0xc3, 0xcc,
	0xc3, 0x3c, 0xcc, 0xff, 0xfe, 0xff, 0xfe, 0xef,
	0xff, 0xdf, 0xff, 0xdd, 0xff, 0xfb, 0xff, 0xfb,
	0xbf, 0xff, 0x7f, 0xff, 0x77, 0xf7, 0xbd, 0xef,
	0xff, 0xf0, 0xff, 0xf0, 0x0f, 0xfc, 0xcc, 0x3c,
	0xcc, 0x33, 0xcc, 0xcf, 0xff, 0xef, 0xff, 0xee,
	0xff, 0xfd, 0xff, 0xfd, 0xdf, 0xff, 0xbf, 0xff,
	0xbb, 0xff, 0xf7, 0xff, 0xf7, 0x7f, 0x7b, 0xde,
};

static const u8 tuning_blk_pattern_8bit[] = {
	0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00,
	0xff, 0xff, 0xcc, 0xcc, 0xcc, 0x33, 0xcc, 0xcc,
	0xcc, 0x33, 0x33, 0xcc, 0xcc, 0xcc, 0xff, 0xff,
	0xff, 0xee, 0xff, 0xff, 0xff, 0xee, 0xee, 0xff,
	0xff, 0xff, 0xdd, 0xff, 0xff, 0xff, 0xdd, 0xdd,
	0xff, 0xff, 0xff, 0xbb, 0xff, 0xff, 0xff, 0xbb,
	0xbb, 0xff, 0xff, 0xff, 0x77, 0xff, 0xff, 0xff,
	0x77, 0x77, 0xff, 0x77, 0xbb, 0xdd, 0xee, 0xff,
	0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0x00,
	0x00, 0xff, 0xff, 0xcc, 0xcc, 0xcc, 0x33, 0xcc,
	0xcc, 0xcc, 0x33, 0x33, 0xcc, 0xcc, 0xcc, 0xff,
	0xff, 0xff, 0xee, 0xff, 0xff, 0xff, 0xee, 0xee,
	0xff, 0xff, 0xff, 0xdd, 0xff, 0xff, 0xff, 0xdd,
	0xdd, 0xff, 0xff, 0xff, 0xbb, 0xff, 0xff, 0xff,
	0xbb, 0xbb, 0xff, 0xff, 0xff, 0x77, 0xff, 0xff,
	0xff, 0x77, 0x77, 0xff, 0x77, 0xbb, 0xdd, 0xee,
};

extern int dw_mci_exynos_request_status(void);
extern void dw_mci_reg_dump(struct dw_mci *host);
