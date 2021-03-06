import yaml
import math
import sys

def writelist(lst):
    return '\n'.join(lst) + '\n\n'

def bus_write(bin_string, idx, val):
    val_in_bin_lst = list(bin(val)[2:])
    val_in_bin_lst.reverse()
    val_in_bin = ''.join(val_in_bin_lst)
    bin_lst = list(bin_string)
    for i, bit in enumerate(val_in_bin, idx):
        bin_lst[(len(bin_string)-1) - i] = bit

    return ''.join(bin_lst)

def define(def_dict):
    defs = []
    for k, v in def_dict.items():
        defs.append(f"`define {k} {v}")

    return defs

def fmt_binary(bin_str):
    return f"{len(bin_str)}'b{bin_str}"

def enum_list(lst, offset=0):
    def_dict = {}
    for i, k in enumerate(lst):
        def_dict[k] = i + offset

    return def_dict

def plain_def(obj):
    defs = define(obj["values"][0])
    return writelist(defs)

def enum(obj):
    num_enum_bits = math.ceil( math.log2( len(obj["values"]) ) )

    def_dict = enum_list(obj["values"])
    def_dict[obj["enum_name"]] = f"{num_enum_bits-1}:0"

    defs = define(def_dict)
    return writelist(defs)

def mux(obj):
    num_ctrl_bits = math.ceil( math.log2( len(obj["signals"]) ) )

    def_dict = {}
    def_dict[obj["mux_name"]] = f"{num_ctrl_bits}:0"
    def_dict.update( enum_list(obj["signals"]) )
    defs = define(def_dict)
    return writelist(defs)

def enc_bus(obj):
    #num_ctrl_bits = math.ceil( math.log2( len(obj["values"]) ) )
    values = obj["values"][0]
    def_dict = {}
    idx = 0

    for value, length in values.items():
        l_int = int(length)
        def_dict[value] = f"{idx + l_int - 1}:{idx}"
        idx += l_int

    def_dict[ obj["bus_name"] ] = f"{idx - 1}:0"

    defs = define(def_dict)
    return writelist(defs)

def control_bus(top_obj):
    bus_idx = 0
    signals = {}
    values = {
            "1": 1,
            "0": 0
            }

    def type(obj):
        return []

    def name(obj):
        return []

    def muxes(obj):
        nonlocal bus_idx
        nonlocal signals
        nonlocal values
        mux_def_dict = {}
        for mux in obj:
            # get the number of bits in mux control signal
            num_mux_bits = math.ceil( math.log2( len(mux["signals"]) ) )

            # add mux and associated control signal range to def dict
            mux_def_dict[mux["mux_name"]] = f"{bus_idx+num_mux_bits-1}:{bus_idx}"

            # add mux to control signals dict
            signals.update( {mux["mux_name"]: bus_idx} )
            bus_idx += num_mux_bits

            # add mux control signals to def dict and values dict
            mux_ctrl_sigs_dict = enum_list(mux["signals"])
            mux_def_dict.update(mux_ctrl_sigs_dict)
            values.update(mux_ctrl_sigs_dict)

        return define(mux_def_dict)

    def encoded_signals(obj):
        print("encoded signals not supported")
        return []

    def control_signals(obj):
        nonlocal bus_idx
        nonlocal signals
        control_signals = enum_list(obj, offset=bus_idx)
        signals.update(control_signals)
        bus_idx += len(obj)
        return define(control_signals)

    def operation_codes(obj):
        nonlocal signals
        nonlocal bus_idx
        opcode_defs = {}
        for opcode in obj:
            ctrl_bus = "0" * (bus_idx)
            for sig_name, sig_val_var in obj[opcode][0].items():
                if sig_name == "opcode":
                    opcode_defs[f"{opcode}_OP"] = fmt_binary(sig_val_var)
                    continue

                sig_idx = signals[sig_name]
                sig_val = values[str(sig_val_var)]
                ctrl_bus = bus_write(ctrl_bus, sig_idx, sig_val)

            opcode_defs[f"{opcode}_CTRL"] = fmt_binary(ctrl_bus)

        return define(opcode_defs)

    control_types = {
            "type": type,
            "muxes": muxes,
            "name": name,
            "encoded_signals": encoded_signals,
            "control_signals": control_signals,
            "operation_codes": operation_codes
            }

    defs = []
    for k, v in top_obj.items():
        defs += control_types[k](v)

    defs += define({top_obj["name"]: f"{bus_idx-1}:0"})
    #print("\nsignals:", signals)
    return writelist(defs)

types = {
        "plain_def": plain_def,
        "enum": enum,
        "mux": mux,
        "control_bus": control_bus,
        "enc_bus": enc_bus
        }

def load(inpput_filename):
    with open(inpput_filename) as f:
        defs_yaml = yaml.safe_load(f)

    return defs_yaml


def generate(defs_yaml, output_filename):
    with open(output_filename, 'w') as f:
        for obj in defs_yaml:
            f.write( types[obj["type"]](obj) )
    
def main():
    defs_yaml = load(sys.argv[1])
    generate(defs_yaml, sys.argv[2])

main()

