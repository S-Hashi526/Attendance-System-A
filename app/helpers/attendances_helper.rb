module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するかを評価
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # 出社でも退社でもない場合はfalse
    false
  end
  
  # 出社時間と退社時間を受け取り、在社時間を計算
  def working_times(start, finish)
    format("%.2f", ((finish - start) / 60 / 60.0))
  end
  
  # 出社時間と退社時間を受け取り、在社時間を計算
  def working_times_check_nextday(attendance)
    start = attendance.started_at.floor_to(15.minutes)

    if attendance.c_bf_nextday
      finish = attendance.finished_at.since(1.days).floor_to(15.minutes)
      format("%.2f", (((finished - start) / 60) / 60.0))
    else
      finish = attendance.finished_at.floor_to(15.minutes)
      format("%.2f", (((finish - start) / 60) / 60.0))
    end
  end
end