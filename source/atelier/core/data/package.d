/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.core.data;

import atelier.common;
import atelier.core.data.logo32;
import atelier.core.data.logo64;
import atelier.core.data.logo128;
import atelier.core.data.vera;

package(atelier.core) void loadInternalData(ResourceManager res) {
    res.write("atelier:logo32", logo32Data);
    res.write("atelier:logo64", logo64Data);
    res.write("atelier:logo128", logo128Data);
    res.write("atelier:vera", veraFontData);
    res.write("atelier:veramono", veraMonoFontData);
}
