/*
 * Copyright (C) 2013 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 * * The names of its contributors may not be used to endorse or promote
 * products derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */


#include "timecomputer.h"

static const quint64 MSEC_IN_DAY = 86400000;

TimeComputer::TimeComputer(QObject *parent) :
    QObject(parent)
{
}

quint64 TimeComputer::remainingMsec(const QDate &date, const QTime &time)
{
    QDateTime eventTimeUtc (date, time, Qt::UTC);
    QDateTime currentTimeUtc = QDateTime::currentDateTimeUtc();

    return currentTimeUtc.msecsTo(eventTimeUtc);
}

quint64 TimeComputer::remainingMsec(int year, int month, int day, int hour, int minute, int second)
{
    QDateTime eventTimeUtc (QDate(year, month, day), QTime(hour, minute, second), Qt::UTC);
    QDateTime currentTimeUtc = QDateTime::currentDateTimeUtc();

    return currentTimeUtc.msecsTo(eventTimeUtc);
}

int TimeComputer::remainingDays(quint64 remainingMsec)
{
    quint64 days = remainingMsec / MSEC_IN_DAY;
    return qMax<quint64>(days, 0);
}

QTime TimeComputer::remainingTime(quint64 remainingMsec)
{
    quint64 time = (remainingMsec - (remainingMsec / MSEC_IN_DAY) * MSEC_IN_DAY);
    int msec = time % 1000;
    time = (time - msec) / 1000;
    int seconds = time % 60;
    time = (time - seconds) / 60;

    int minutes = time % 60;
    time = (time - minutes) / 60;

    return QTime(qMax<int>(time, 0), qMax<int>(minutes, 0),
                 qMax<int>(seconds, 0), qMax<int>(msec, 0));
}
