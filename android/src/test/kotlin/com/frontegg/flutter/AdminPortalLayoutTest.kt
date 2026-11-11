package com.frontegg.flutter

import com.frontegg.android.AdminPortalLayout
import kotlin.test.Test
import kotlin.test.assertEquals

internal class AdminPortalLayoutTest {

    @Test
    fun responsiveValue_opensTheResponsiveLayout() {
        assertEquals(AdminPortalLayout.RESPONSIVE, adminPortalLayoutFrom("responsive"))
    }

    @Test
    fun desktopMissingOrUnknownValue_opensTheDesktopLayout() {
        assertEquals(AdminPortalLayout.DESKTOP, adminPortalLayoutFrom("desktop"))
        assertEquals(AdminPortalLayout.DESKTOP, adminPortalLayoutFrom(null))
        assertEquals(AdminPortalLayout.DESKTOP, adminPortalLayoutFrom("tablet"))
    }
}
