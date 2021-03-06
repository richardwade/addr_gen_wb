library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.wishbone_pkg.all;
use work.MAIN_wb_pkg.all;

entity main is

  port (
    rst_n_i   : in  std_logic;
    clk_sys_i : in  std_logic;
    clk_io_i  : in  std_logic;
    wb_s_in   : in  t_wishbone_slave_in;
    wb_s_out  : out t_wishbone_slave_out
    );

end entity main;

architecture rtl of main is
  signal LINKS_wb_m_o  : t_wishbone_master_out_array(0 to 4);
  signal LINKS_wb_m_i  : t_wishbone_master_in_array(0 to 4);
  signal EXTERN_wb_m_o : t_wishbone_master_out;
  signal EXTERN_wb_m_i : t_wishbone_master_in;
  signal CDC_wb_m_o    : t_wishbone_master_out;
  signal CDC_wb_m_i    : t_wishbone_master_in;
  signal CTRL_o        : t_CTRL;
begin  -- architecture rtl

  MAIN_wb_1 : entity work.MAIN_wb
    port map (
      slave_i       => wb_s_in,
      slave_o       => wb_s_out,
      LINKS_wb_m_o  => LINKS_wb_m_o,
      LINKS_wb_m_i  => LINKS_wb_m_i,
      EXTERN_wb_m_o => CDC_wb_m_o,
      EXTERN_wb_m_i => CDC_wb_m_i,
      CTRL_o        => CTRL_o,
      rst_n_i       => rst_n_i,
      clk_sys_i     => clk_sys_i);

  wb_cdc_1 : entity work.wb_cdc
    generic map (
      width => 32)
    port map (
      slave_clk_i    => clk_sys_i,
      slave_rst_n_i  => rst_n_i,
      slave_i        => CDC_wb_m_o,
      slave_o        => CDC_wb_m_i,
      master_clk_i   => clk_io_i,
      master_rst_n_i => rst_n_i,
      master_i       => EXTERN_wb_m_i,
      master_o       => EXTERN_wb_m_o);

  gl1 : for i in 0 to 4 generate

    sys1_1 : entity work.sys1
      port map (
        rst_n_i   => rst_n_i,
        clk_sys_i => clk_sys_i,
        wb_s_in   => LINKS_wb_m_o(i),
        wb_s_out  => LINKS_wb_m_i(i));

  end generate gl1;

  ext_1 : entity work.exttest
    generic map (
      instance_number => 1,
      addr_size       => 10
      )
    port map (
      rst_n_i   => rst_n_i,
      clk_sys_i => clk_sys_i,
      wb_s_in   => EXTERN_wb_m_o,
      wb_s_out  => EXTERN_wb_m_i);

end architecture rtl;
