{
  beta = {
    deps = {
      gn = {
        rev = "811d332bd90551342c5cbd39e133aa276022d7f8";
        sha256 = "0jlg3d31p346na6a3yk0x29pm6b7q03ck423n5n6mi8nv4ybwajq";
        url = "https://gn.googlesource.com/gn";
        version = "2023-08-01";
      };
    };
    sha256 = "0c3adrrgpnhm8g1546ask9pf17qj1sjgb950mj0rv4snxvddi75j";
    sha256bin64 = "11w1di146mjb9ql30df9yk9x4b9amc6514jzyfbf09mqsrw88dvr";
    version = "117.0.5938.22";
  };
  dev = {
    deps = {
      gn = {
        rev = "cc56a0f98bb34accd5323316e0292575ff17a5d4";
        sha256 = "1ly7z48v147bfdb1kqkbc98myxpgqq3g6vgr8bjx1ikrk17l82ab";
        url = "https://gn.googlesource.com/gn";
        version = "2023-08-10";
      };
    };
    sha256 = "16dq27lsywrn2xlgr5g46gdv15p30sihfamli4vkv3zxzfxdjisv";
    sha256bin64 = "11y09hsy7y1vg65xfilq44ffsmn15dqy80fa57psj1kin4a52v2x";
    version = "118.0.5966.0";
  };
  stable = {
    chromedriver = {
      sha256_darwin = "01zdbi7fb6hcfhvqj6qfibf8ffas7f2qc7psr4q69hzdd8ns0hyv";
      sha256_darwin_aarch64 =
        "16l22jwbdx8ry7ypqjj0wn0dad7rp0jjlk893vvykdjxagikb8pd";
      sha256_linux = "09vdvnqgk2ryarsw7a75a2hb1a9cl31g6kwipr1l9vdw2mgb37l0";
      version = "120.0.6099.109";
    };
    deps = {
      gn = {
        rev = "e4702d7409069c4f12d45ea7b7f0890717ca3f4b";
        sha256 = "1fbkpdsxbma41yja4s27j4i3f1pa38784f8knhq9plzawwc6w2bp";
        url = "https://gn.googlesource.com/gn";
        version = "2023-10-23";
      };
    };
    sha256 = "01w2k6xvprghnyqisrxpbwc48d5fv5831fx71mamrh08phw96ggr";
    sha256bin64 = "0mxsh8d0gahgqqkh7r498kv46aq07561672ard8s33pc6s0pal6h";
    version = "120.0.6099.129";
  };
  ungoogled-chromium = {
    deps = {
      gn = {
        rev = "e4702d7409069c4f12d45ea7b7f0890717ca3f4b";
        sha256 = "1fbkpdsxbma41yja4s27j4i3f1pa38784f8knhq9plzawwc6w2bp";
        url = "https://gn.googlesource.com/gn";
        version = "2023-10-23";
      };
      ungoogled-patches = {
        rev = "120.0.6099.129-1";
        sha256 = "02d1wav4r0gfbm37qbh8yaqg5gdihz5cl75krc3837cizxml0n4i";
      };
    };
    sha256 = "01w2k6xvprghnyqisrxpbwc48d5fv5831fx71mamrh08phw96ggr";
    sha256bin64 = "0mxsh8d0gahgqqkh7r498kv46aq07561672ard8s33pc6s0pal6h";
    version = "120.0.6099.129";
  };
}
